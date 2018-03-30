import Vapor

final class StoragesConfiguration: Codable  {
    
    // MARK: - Публичные свойства
    
    /// Склады
    let storages: [String]
    /// Информация о складах
    let info: [StorageInfoConfiguration]
    
    
    // MARK: - Инициализация
    
    init(storages: [String], info: [StorageInfoConfiguration]) {
        self.storages = storages
        self.info = info
    }
}


// MARK: - Content

extension StoragesConfiguration: Content { }
