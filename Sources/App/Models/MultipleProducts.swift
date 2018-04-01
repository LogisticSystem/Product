import Vapor

final class MultipleProducts: Codable {
    
    // MARK: - Публичные свойства
    
    /// Товары
    var products: [ProductPublic]
    
    
    // MARK: - Инициализация
    
    init(products: [ProductPublic]) {
        self.products = products
    }
}


// MARK: - Content

extension MultipleProducts: Content { }
