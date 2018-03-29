import Vapor

final class MultipleProducts: Codable {
    
    var products: [Product]
    
    init(products: [Product]) {
        self.products = products
    }
}


// MARK: - Content

extension MultipleProducts: Content { }
