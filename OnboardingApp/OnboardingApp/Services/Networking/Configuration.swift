import Foundation

struct Configuration {
    let baseURL: String
    let timeoutInterval: TimeInterval
    let cachePolicy: URLRequest.CachePolicy
    
    static let `default` = Configuration(baseURL: API.baseURL, timeoutInterval: API.timeout, cachePolicy: .useProtocolCachePolicy)
}
