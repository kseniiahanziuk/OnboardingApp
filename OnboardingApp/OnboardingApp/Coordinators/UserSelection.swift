import Foundation

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
