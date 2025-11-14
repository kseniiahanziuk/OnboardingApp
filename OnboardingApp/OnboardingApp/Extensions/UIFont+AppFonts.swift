import UIKit

extension UIFont {
    // MARK: - Fonts
    static let titleFont = sf(size: 26, weight: .bold)
    static let questionFont = sf(size: 20, weight: .semibold)
    static let answerFont = sf(size: 16, weight: .medium)
    static let buttonFont = sf(size: 17, weight: .semibold)
    static let subtitleFont = sf(size: 16, weight: .medium)
    static let captionFont = sf(size: 12, weight: .regular)
    static let paywallTitleFont = sf(size: 32, weight: .bold)
}

// MARK: - Extension for a function for easier usage of UIFont
extension UIFont {
    static func sf(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
