import Vapor

final class NavigatorRouteInfo: Codable {
    
    // MARK: - Публичные свойства
    
    /// Начальная точка маршрута
    let source: String
    /// Конечная точка маршрута
    let destination: String
    /// Маршрут
    let storages: [String]
    
    
    // MARK: - Инициализация
    
    init(source: String, destination: String, storages: [String]) {
        self.source = source
        self.destination = destination
        self.storages = storages
    }
}


// MARK: - Content

extension NavigatorRouteInfo: Content { }
