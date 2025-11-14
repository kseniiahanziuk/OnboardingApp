import Foundation

struct OnboardingCard: Codable {
    let id: Int
    let question: String
    let answers: [String]
    
    var answerObjects: [OnboardingAnswer] {
        return answers.enumerated().map { index, answerText in
            OnboardingAnswer(id: "\(id)-\(index)", title: answerText)
        }
    }
}
