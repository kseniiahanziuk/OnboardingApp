import UIKit

final class OnboardingCoordinator: NSObject {
    weak var delegate: OnboardingCoordinatorDelegate?
    
    private let navigationController: UINavigationController
    private let networkService: NetworkServiceProtocol
    
    private var cards: [OnboardingCard] = []
    private var currentIndex = 0
    private var userSelections: [UserSelection] = []
    
    private var isLoading = false
    
    init(navigationController: UINavigationController,
         networkService: NetworkServiceProtocol = NetworkService()) {
        self.navigationController = navigationController
        self.networkService = networkService
        super.init()
        
        self.navigationController.delegate = self
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        loadOnboarding()
    }
    
    private func loadOnboarding() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let cards = try await networkService.fetchOnboarding()
                await MainActor.run {
                    self.isLoading = false
                    self.cards = cards
                    
                    guard !cards.isEmpty else {
                        self.showError(.noData)
                        return
                    }
                    
                    self.showNextCard()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showError(error as? NetworkError ?? .unknown)
                }
            }
        }
    }
    
    private func showNextCard() {
        guard currentIndex < cards.count else {
            showPaywall()
            return
        }
        
        let card = cards[currentIndex]
        let questionVC = QuestionViewController(card: card)
        questionVC.delegate = self
        
        navigationController.pushViewController(questionVC, animated: currentIndex > 0)
    }
    
    private func showPaywall() {
        // TODO: Implement PaywallViewController
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        saveSelectionsToUserDefaults()
        
        delegate?.onboardingDidComplete()
    }
    
    private func saveSelectionsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(userSelections) {
            UserDefaults.standard.set(encoded, forKey: "onboardingSelections")
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
    }
    
    private func showError(_ error: NetworkError) {
        let alert = UIAlertController(
            title: "Oops!",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
            self?.loadOnboarding()
        })
        
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel) { [weak self] _ in
            self?.completeOnboarding()
        })
        
        navigationController.present(alert, animated: true)
    }
}

// MARK: - QuestionRxDelegate
extension OnboardingCoordinator: QuestionRxDelegate {
    func didSelectOption(cardId: Int, answerId: String) {
        let selection = UserSelection(cardId: cardId, answerId: answerId)
        userSelections.append(selection)
        
        // Log for debugging
        print("User selected answer '\(answerId)' for card \(cardId)")
        
        currentIndex += 1
        showNextCard()
    }
}

// MARK: - UINavigationControllerDelegate
extension OnboardingCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return OnboardingTransitionAnimator()
    }
}

// MARK: - OnboardingTransitionAnimator
final class OnboardingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        toView.alpha = 0
        toView.transform = CGAffineTransform(translationX: 50, y: 0)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut,
            animations: {
                toView.alpha = 1
                toView.transform = .identity
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
}

// MARK: - Helper extension
extension OnboardingCoordinator {
    static func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    static func getUserSelections() -> [UserSelection]? {
        guard let data = UserDefaults.standard.data(forKey: "onboardingSelections"),
              let selections = try? JSONDecoder().decode([UserSelection].self, from: data) else {
            return nil
        }
        return selections
    }
    
    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "onboardingSelections")
        UserDefaults.standard.removeObject(forKey: "hasPremiumAccess")
    }
}

struct UserSelection: Codable {
    let cardId: Int
    let answerId: String
    let timestamp: Date
    
    init(cardId: Int, answerId: String) {
        self.cardId = cardId
        self.answerId = answerId
        self.timestamp = Date()
    }
}
