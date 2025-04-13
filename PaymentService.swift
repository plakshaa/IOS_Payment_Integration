import Foundation

enum PaymentError: Error {
    case networkError
    case invalidResponse
    case paymentFailed
}

class PaymentService {
    static let shared = PaymentService()
    private let baseURL = "YOUR_BACKEND_API_URL"
    
    private init() {}
    
    func createPaymentIntent(amount: Int, currency: String = "usd") async throws -> String {
        guard let url = URL(string: "\(baseURL)/create-payment-intent") else {
            throw PaymentError.invalidResponse
        }
        
        let parameters: [String: Any] = [
            "amount": amount,
            "currency": currency
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PaymentError.networkError
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let clientSecret = json["clientSecret"] as? String else {
            throw PaymentError.invalidResponse
        }
        
        return clientSecret
    }
    
    func confirmPayment(paymentIntentId: String) async throws {
        guard let url = URL(string: "\(baseURL)/confirm-payment") else {
            throw PaymentError.invalidResponse
        }
        
        let parameters: [String: Any] = [
            "paymentIntentId": paymentIntentId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PaymentError.paymentFailed
        }
    }
} 