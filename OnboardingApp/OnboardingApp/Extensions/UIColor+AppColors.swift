import UIKit

extension UIColor {
    // MARK: - App background color
    static let appBackground = UIColor.systemGray6
    
    // MARK: - Button colors
    static let selectedAnswer = UIColor.hex("#47BE9A")
    static let unselectedAnswer = UIColor.hex("#FFFFFF")

    static let ctaButton = UIColor.hex("#101B18")
    static let ctaButtonDisabled = UIColor.hex("#FFFFFF")
    
    // MARK: - Text colors
    static let disabledText = UIColor.hex("#CACACA")
    
    static let primaryText = UIColor.label
    static let tertiaryText = UIColor.tertiaryLabel
    static let secondaryText = UIColor.secondaryLabel
}

// MARK: - Extension for hex translation to UIColor
extension UIColor {
    static func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHex = cleanHex.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat((rgb & 0x0000FF)) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
