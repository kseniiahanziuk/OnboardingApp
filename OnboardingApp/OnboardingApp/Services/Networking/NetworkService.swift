import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(configuration: Configuration = .default) {
        self.baseURL = configuration.baseURL
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfig.timeoutIntervalForResource = configuration.timeoutInterval
        sessionConfig.requestCachePolicy = configuration.cachePolicy
        
        self.session = URLSession(configuration: sessionConfig)
        self.decoder = JSONDecoder()
    }
    
    func fetchOnboarding() async throws -> [OnboardingCard] {
        let response: OnboardingResponse = try await request(endpoint: API.onboardingEndpoint, method: .get, parameters: nil)
        
        guard !response.items.isEmpty else {
            throw NetworkError.noData
        }
        
        return response.items
    }
    
    func request<T>(endpoint: String, method: HTTPMethod = .get, parameters: [String : Any]? = nil) async throws -> T where T : Decodable {
        guard let url = buildURL(endpoint: endpoint, parameters: method == HTTPMethod.get ? parameters : nil) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if method != HTTPMethod.get, let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            try validateResponse(response)
            
            do {
                let decodedResponse = try decoder.decode(T.self, from: data)
                return decodedResponse
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw handleURLError(error)
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}

extension NetworkService {
    private func buildURL(endpoint: String, parameters: [String: Any]?) -> URL? {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            return nil
        }
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        return urlComponents.url
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 404:
            throw NetworkError.notFound
        case 400...499:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.unknown
        }
    }
    
    private func handleURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkError(error)
        default:
            return .networkError(error)
        }
    }
}
