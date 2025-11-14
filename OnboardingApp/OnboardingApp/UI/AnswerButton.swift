import UIKit
import SnapKit

final class AnswerButton: UIButton {
    private let title: String
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        setTitle(title, for: .normal)
        titleLabel?.font = .answerFont
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        
        contentHorizontalAlignment = .left
        contentEdgeInsets = UIEdgeInsets(top: CGFloat.spacingS, left: CGFloat.spacingM, bottom: CGFloat.spacingS, right: CGFloat.spacingM)
        layer.cornerRadius = 16
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        updateAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    private func updateAppearance() {
        if isSelected {
            backgroundColor = .selectedAnswer
            setTitleColor(.white, for: .normal)
            layer.borderWidth = 0
            layer.shadowOpacity = 0.15
        } else {
            backgroundColor = .unselectedAnswer
            setTitleColor(.primaryText, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor.systemGray5.cgColor
            layer.shadowOpacity = 0.05
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel?.sizeThatFits(CGSize(width: bounds.width - CGFloat.spacingM * 2, height: .greatestFiniteMagnitude)) ?? .zero
        let height = max(56, labelSize.height + CGFloat.spacingM * 2)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}
