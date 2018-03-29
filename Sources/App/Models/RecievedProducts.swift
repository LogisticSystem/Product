import Vapor

final class RecievedProducts: Codable {
    
    var products: [StorageProduct]
    var transportId: String?
    
    init(products: [StorageProduct], transportId: String?) {
        self.products = products
        self.transportId = transportId
    }
}


// MARK: - Content

extension RecievedProducts: Content { }
