import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int)
    case networkError(Error)
    case timeout
    case notFound
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from the server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with code \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Timeout on request"
        case .notFound:
            return "Resource cannot be found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
