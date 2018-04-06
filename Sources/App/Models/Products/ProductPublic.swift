import Vapor

final class ProductPublic: Codable {
    
    // MARK: - Публичные свойства
    
    /// Идентификатор товара
    var id: String
    /// Идентификатор точки отправления
    var source: String
    /// Идентификатор точки прибытия
    var destination: String
    /// Маршрут
    var route: [String]
    
    
    // MARK: - Инициализация
    
    init(id: String, source: String, destination: String, route: [String]) {
        self.id = id
        self.source = source
        self.destination = destination
        self.route = route
    }
}


// MARK: - Публичные свойства

extension ProductPublic {
    
    /// Товар
    var productPrivate: Product {
        return Product(id: self.id, source: self.source, destination: self.destination, route: self.route, ownerId: nil)
    }
}


// MARK: - Content

extension ProductPublic: Content { }
