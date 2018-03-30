import Vapor

final class StoragePrepareProductsRequest: Codable {
    
    // MARK: - Публичные свойства
    
    /// Количество товаров
    var capacity: Int?
    /// Возможные пунты прибытия
    var accessiblePoints: [String]?
    
    
    // MARK: - Инициализация
    
    init(capacity: Int?, accessiblePoints: [String]?) {
        self.capacity = capacity
        self.accessiblePoints = accessiblePoints
    }
}


// MARK: - Content

extension StoragePrepareProductsRequest: Content { }
