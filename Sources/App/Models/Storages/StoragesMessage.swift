import Vapor

final class StoragesMessage: Codable {
    
    // MARK: - Публичные свойства
    
    /// Действие
    var action: String
    /// Товары
    var products: [StorageProduct]
    /// Идентификатор склада
    var storageId: String
    /// Идентификатор транспорта
    var transportId: String
    
    
    // MARK: - Инициализация
    
    init(action: String, products: [StorageProduct], storageId: String, transportId: String) {
        self.action = action
        self.products = products
        self.storageId = storageId
        self.transportId = transportId
    }
}


// MARK: - Content

extension StoragesMessage: Content { }
