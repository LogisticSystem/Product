import Foundation
import Vapor

final class Product: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор товара
    var id: String
    /// Идентификатор точки отправления
    var source: String
    /// Идентификатор точки прибытия
    var destination: String
    /// Маршрут
    var route: [String]
    /// Идентификатор владельца
    var ownerId: String?
    
    
    // MARK: - Инициализация
    
    init(id: String = UUID().uuidString, source: String, destination: String, route: [String], ownerId: String?) {
        self.id = id
        self.source = source
        self.destination = destination
        self.route = route
        self.ownerId = ownerId
    }
}


// MARK: - Content

extension Product: Content { }
