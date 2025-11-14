import Foundation

protocol QuestionRxDelegate: AnyObject {
    func didSelectOption(cardId: Int, answerId: String)
}
