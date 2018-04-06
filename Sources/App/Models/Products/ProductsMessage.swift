import Vapor

final class ProductsMessage: Codable {
    
    // MARK: - Публичные свойства
    
    /// Действие
    var action: String
    /// Товары
    var products: [Product]
    
    
    // MARK: - Инициализация
    
    init(action: String, products: [Product]) {
        self.action = action
        self.products = products
    }
}


// MARK: - Content

extension ProductsMessage: Content { }
