import Vapor

final class StorageConnectionConfiguration: Codable {
    
    // MARK: - Публичные свойства
    
    /// Название склада
    let name: String
    /// Вес связи
    let weight: Int
    
    
    // MARK: - Инициализация
    
    init(name: String, weight: Int) {
        self.name = name
        self.weight = weight
    }
}


// MARK: - Content

extension StorageConnectionConfiguration: Content { }
