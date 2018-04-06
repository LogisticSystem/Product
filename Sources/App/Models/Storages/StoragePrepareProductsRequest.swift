import Vapor

final class StoragePrepareProductsRequest: Codable {
    
    // MARK: - Публичные свойства
    
    /// Количество товаров
    var capacity: Int?
    /// Возможные пунты прибытия
    var accessiblePoints: [String]?
    /// Идентификатор транспорта
    var transportId: String
    
    
    // MARK: - Инициализация
    
    init(capacity: Int?, accessiblePoints: [String]?, transportId: String) {
        self.capacity = capacity
        self.accessiblePoints = accessiblePoints
        self.transportId = transportId
    }
}


// MARK: - Content

extension StoragePrepareProductsRequest: Content { }
