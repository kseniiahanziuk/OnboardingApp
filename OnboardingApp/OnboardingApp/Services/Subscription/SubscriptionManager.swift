import StoreKit
import Foundation

final class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    private(set) var products: [Product] = []
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func loadProducts() async throws {
        // Since there was no specified App Store id, for now, this is a placeholder that won't work without proper setup
        let productIds: Set<String> = [AppConfiguration.productIdentifier]
        
        do {
            products = try await Product.products(for: productIds)
        } catch {
            print("Failed to load products: \(error)")
            throw error
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            
        case .userCancelled:
            throw SubscriptionError.userCancelled
            
        case .pending:
            throw SubscriptionError.pending
            
        @unknown default:
            throw SubscriptionError.unknown
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    func hasActiveSubscription() async -> Bool {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productType == .autoRenewable {
                    return true
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        return false
    }
}
