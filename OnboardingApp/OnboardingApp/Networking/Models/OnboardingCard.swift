import Foundation

struct OnboardingCard: Codable {
    let id: Int
    let question: String
    let answers: [String]
    
    var options: [OnboardingOption] {
        return answers.enumerated().map { index, answer in
            OnboardingOption(id: "\(id)-\(index)", title: answer)
        }
    }
}
