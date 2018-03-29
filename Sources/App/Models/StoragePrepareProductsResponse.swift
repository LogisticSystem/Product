import Vapor

final class StoragePrepareProductsResponse: Codable {
    
    var products: [StorageProduct]
    
    init(products: [StorageProduct]) {
        self.products = products
    }
}


// MARK: - Content

extension StoragePrepareProductsResponse: Content { }
