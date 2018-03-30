import Vapor

final class MultipleProducts: Codable {
    
    // MARK: - Публичные свойства
    
    /// Товары
    var products: [Product]
    
    
    // MARK: - Инициализация
    
    init(products: [Product]) {
        self.products = products
    }
}


// MARK: - Content

extension MultipleProducts: Content { }
