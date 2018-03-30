import Vapor

final class Storage: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор склада
    var id: String
    /// Товары
    var products: [StorageProduct]
    
    
    // MARK: - Инициализация
    
    init(id: String, products: [StorageProduct]) {
        self.id = id
        self.products = products
    }
}


// MARK: - Content

extension Storage: Content { }
