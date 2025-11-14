import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class QuestionViewController: UIViewController {
    weak var delegate: QuestionRxDelegate?
    
    private let card: OnboardingCard
    private let disposeBag = DisposeBag()
    private let selectedAnswerRelay = BehaviorRelay<String?>(value: nil)
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Let's setup App for you"
        label.font = .titleFont
        label.numberOfLines = 0
        return label
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .questionFont
        label.numberOfLines = 0
        return label
    }()
    
    private let answersStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = CGFloat.spacingS
        stack.distribution = .fill
        return stack
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .buttonFont
        button.layer.cornerRadius = 28
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.disabledText, for: .disabled)
        button.backgroundColor = .ctaButtonDisabled
        button.isEnabled = false
        
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: -4)
        button.layer.shadowRadius = 18
        button.layer.masksToBounds = false
        
        return button
    }()
    
    private var answerButtons : [String: AnswerButton] = [:]
    
    init(card: OnboardingCard) {
        self.card = card
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
        bindRx()
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(questionLabel)
        contentView.addSubview(answersStackView)
        
        view.addSubview(continueButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).offset(-CGFloat.spacingM)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.spacingXXL)
            make.leading.equalToSuperview().offset(CGFloat.spacingL)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingL)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(CGFloat.spacingXXL)
            make.leading.equalToSuperview().offset(CGFloat.spacingL)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingL)
        }
        
        answersStackView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(CGFloat.spacingL)
            make.leading.equalToSuperview().offset(CGFloat.spacingL)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingL)
            make.bottom.equalToSuperview().offset(-CGFloat.spacingL)
        }
        
        continueButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(CGFloat.spacingL)
            make.trailing.equalToSuperview().offset(-CGFloat.spacingL)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-CGFloat.spacingXXXL)
            make.height.equalTo(56)
        }
    }
    
    private func configureContent() {
        questionLabel.text = card.question
        
        for answer in card.answerObjects {
            let button = AnswerButton(title: answer.title)
            answerButtons[answer.id] = button
            answersStackView.addArrangedSubview(button)
            
            button.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(56)
            }
            
            button.rx.tap.map { [weak self, weak button, answerId = answer.id] _ -> String? in
                guard let self = self, let button = button else {
                    return nil
                }
                
                self.answerButtons.values.forEach { $0.isSelected = false }
                button.isSelected = true
                
                return answerId
            }
            .bind(to: selectedAnswerRelay)
            .disposed(by: disposeBag)
        }
    }
    
    private func bindRx() {
        selectedAnswerRelay
            .map { $0 != nil }
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        selectedAnswerRelay
            .subscribe(onNext: { [weak self] answerId in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.2) {
                    if answerId != nil {
                        self.continueButton.backgroundColor = .ctaButton
                    } else {
                        self.continueButton.backgroundColor = .ctaButtonDisabled
                    }
                }
            })
            .disposed(by: disposeBag)
        
        continueButton.rx.tap
            .withLatestFrom(selectedAnswerRelay)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] answerId in
                guard let self = self else { return }
                self.delegate?.didSelectOption(cardId: self.card.id, answerId: answerId)
            })
            .disposed(by: disposeBag)
    }
}
