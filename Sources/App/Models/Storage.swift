import Vapor

final class Storage: Codable {
    
    var id: String
    var products: [StorageProduct]
    
    init(id: String, products: [StorageProduct]) {
        self.id = id
        self.products = products
    }
}


// MARK: - Content

extension Storage: Content { }
