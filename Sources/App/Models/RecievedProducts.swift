import Vapor

final class RecievedProducts: Codable {
    
    // MARK: - Публичные свойства
    
    /// Товары
    var products: [StorageProduct]
    /// Идентификатор транспорта
    var transportId: String?
    
    
    // MARK: - Инициализация
    
    init(products: [StorageProduct], transportId: String?) {
        self.products = products
        self.transportId = transportId
    }
}


// MARK: - Content

extension RecievedProducts: Content { }
