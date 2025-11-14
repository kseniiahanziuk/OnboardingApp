import UIKit
import SnapKit
import StoreKit

final class PaywallViewController: UIViewController {
    weak var delegate: PaywallViewControllerDelegate?
    private let subscriptionManager = SubscriptionManager.shared
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        
        if let image = UIImage(named: "CancelSaleScreen") {
            button.setImage(image, for: .normal)
        } else {
            let image = UIImage(systemName: "xmark", withConfiguration: config)
            button.setImage(image, for: .normal)
        }
        button.tintColor = .black
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        if let image = UIImage(named: "Onboarding4Light") {
            imageView.image = image
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .light)
            let placeholderImage = UIImage(systemName: "photo", withConfiguration: config)
            imageView.image = placeholderImage
        }
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover all\nPremium features"
        label.font = .paywallTitleFont
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .subtitleFont
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Now", for: .normal)
        button.titleLabel?.font = .buttonFont
        button.backgroundColor = UIColor.hex("#101B18")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 28
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.font = .captionFont
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.hex("#101B18")
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTermsAndLinks()
        loadProducts()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        view.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        view.addSubview(startButton)
        view.addSubview(termsLabel)
        view.addSubview(activityIndicator)
        
        setupConstraints()
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(450)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(startButton.snp.top).offset(-CGFloat.spacingM)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(CGFloat.spacingXS)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingXL)
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.spacingXXL)
            make.leading.equalToSuperview().offset(CGFloat.spacingL)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingL)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(CGFloat.spacingM)
            make.leading.equalToSuperview().offset(CGFloat.spacingL)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingL)
            make.bottom.equalToSuperview().offset(-CGFloat.spacingL)
        }
        
        startButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(CGFloat.spacingXL)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingXL)
            make.bottom.equalTo(termsLabel.snp.top).offset(-CGFloat.spacingXM)
            make.height.equalTo(56)
        }
        
        termsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(CGFloat.spacingL)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingL)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-CGFloat.spacingM)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupInitialSubtitle() {
        let fullText = "Try 7 days for free\nthen $6.99 per week, auto-renewable"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.gray,
            range: NSRange(location: 0, length: fullText.count)
        )
        
        attributedString.addAttribute(
            .font,
            value: UIFont.subtitleFont,
            range: NSRange(location: 0, length: fullText.count)
        )
        
        if let priceRange = fullText.range(of: "$6.99") {
            let nsRange = NSRange(priceRange, in: fullText)
            attributedString.addAttribute(
                .font,
                value: UIFont.systemFont(ofSize: 16, weight: .bold),
                range: nsRange
            )
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.black,
                range: nsRange
            )
        }
        
        subtitleLabel.attributedText = attributedString
    }
    
    private func setupTermsAndLinks() {
        let fullText = "By continuing you accept our:\nTerms of Use, Privacy Policy, Subscription Terms"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.gray,
            range: NSRange(location: 0, length: fullText.count)
        )
        
        let linksText = "Terms of Use, Privacy Policy, Subscription Terms"
        if let linksRange = fullText.range(of: linksText) {
            let nsRange = NSRange(linksRange, in: fullText)
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.systemBlue,
                range: nsRange
            )
        }
        
        termsLabel.attributedText = attributedString
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap))
        termsLabel.addGestureRecognizer(tapGesture)
    }
    
    private func loadProducts() {
        activityIndicator.startAnimating()
        
        setupInitialSubtitle()
        
        Task {
            do {
                try await subscriptionManager.loadProducts()
                await MainActor.run {
                    updateUI()
                }
            } catch {
                print("Failed to load products: \(error)")
                await MainActor.run {
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @MainActor
    private func updateUI() {
        activityIndicator.stopAnimating()
        
        guard let product = subscriptionManager.products.first else {
            return
        }
        
        let priceString = product.displayPrice
        let fullText = "Try 7 days for free\nthen \(priceString) per week, auto-renewable"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.gray,
            range: NSRange(location: 0, length: fullText.count)
        )
        
        attributedString.addAttribute(
            .font,
            value: UIFont.subtitleFont,
            range: NSRange(location: 0, length: fullText.count)
        )
        
        if let priceRange = fullText.range(of: priceString) {
            let nsRange = NSRange(priceRange, in: fullText)
            attributedString.addAttribute(
                .font,
                value: UIFont.systemFont(ofSize: 16, weight: .bold),
                range: nsRange
            )
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.black,
                range: nsRange
            )
        }
        
        subtitleLabel.attributedText = attributedString
    }
    
    @objc
    private func closeButtonTapped() {
        delegate?.didClose()
    }
    
    @objc
    private func startButtonTapped() {
        guard let product = subscriptionManager.products.first else {
            showError("Product not available")
            return
        }
        
        startButton.isEnabled = false
        activityIndicator.startAnimating()
        
        Task {
            do {
                try await subscriptionManager.purchase(product)
                await MainActor.run {
                    UserDefaults.standard.set(true, forKey: "hasPremiumAccess")
                    delegate?.didCompletePurchase()
                }
            } catch let error as SubscriptionError {
                if error == .userCancelled {
                    await MainActor.run {
                        startButton.isEnabled = true
                        activityIndicator.stopAnimating()
                    }
                } else {
                    await MainActor.run {
                        self.showError("Purchase failed. Please try again.")
                        startButton.isEnabled = true
                        activityIndicator.stopAnimating()
                    }
                }
            } catch {
                await MainActor.run {
                    self.showError("Purchase failed. Please try again.")
                    startButton.isEnabled = true
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @objc
    private func handleLinkTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: termsLabel)
        let textStorage = NSTextStorage(attributedString: termsLabel.attributedText!)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: termsLabel.bounds.size)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = termsLabel.numberOfLines
        textContainer.lineBreakMode = termsLabel.lineBreakMode
        
        let characterIndex = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        let fullText = "By continuing you accept our:\nTerms of Use, Privacy Policy, Subscription Terms"
        let linksText = "Terms of Use, Privacy Policy, Subscription Terms"
        
        if let linksRange = fullText.range(of: linksText) {
            let nsRange = NSRange(linksRange, in: fullText)
            if NSLocationInRange(characterIndex, nsRange) {
                if let url = URL(string: "https://www.apple.com/legal/privacy/") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
