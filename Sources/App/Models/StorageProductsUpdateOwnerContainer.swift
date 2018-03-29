import Vapor

final class StorageProductsUpdateOwnerContainer: Codable {
    
    var products: [StorageProduct]
    
    init(products: [StorageProduct]) {
        self.products = products
    }
}


// MARK: - Content

extension StorageProductsUpdateOwnerContainer: Content { }
