import UIKit
import Stripe
import StripePaymentSheet

class PaymentViewController: UIViewController {
    
    // MARK: - Properties
    private let paymentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pay Now", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount: $99.99"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var paymentSheet: PaymentSheet?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStripe()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Payment"
        
        view.addSubview(amountLabel)
        view.addSubview(paymentButton)
        
        NSLayoutConstraint.activate([
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            paymentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentButton.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 30),
            paymentButton.widthAnchor.constraint(equalToConstant: 200),
            paymentButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        paymentButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
    }
    
    private func setupStripe() {
        // Replace with your Stripe publishable key
        StripeAPI.defaultPublishableKey = "pk_test_YOUR_PUBLISHABLE_KEY"
        
        // Create payment sheet configuration
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Your App Name"
        configuration.defaultBillingDetails.address.country = "US"
        
        // Create payment sheet
        paymentSheet = PaymentSheet(paymentIntentClientSecret: "YOUR_PAYMENT_INTENT_CLIENT_SECRET",
                                  configuration: configuration)
    }
    
    // MARK: - Actions
    @objc private func paymentButtonTapped() {
        guard let paymentSheet = paymentSheet else { return }
        
        paymentSheet.present(from: self) { [weak self] result in
            switch result {
            case .completed:
                self?.showAlert(title: "Success", message: "Payment completed successfully!")
            case .failed(let error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            case .canceled:
                print("Payment canceled")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 