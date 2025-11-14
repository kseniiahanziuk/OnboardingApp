import Foundation

protocol NetworkServiceProtocol {
    func fetchOnboarding() async throws -> [OnboardingCard]
    
    func request<T:Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?
    ) async throws -> T
}
