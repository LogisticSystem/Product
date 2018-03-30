import Vapor

final class StorageInfoConfiguration: Codable {
    
    // MARK: - Публичные свойства
    
    /// Нащвание склада
    let name: String
    /// Связи склада
    let connections: [StorageConnectionConfiguration]
    
    
    // MARK: - Инициализация
    
    init(name: String, connections: [StorageConnectionConfiguration]) {
        self.name = name
        self.connections = connections
    }
}


// MARK: - Content

extension StorageInfoConfiguration: Content { }
