import Vapor

final class StoragesConfiguration: Codable  {
    
    let storages: [String]
    let info: [StorageInfoConfiguration]
    
    init(storages: [String], info: [StorageInfoConfiguration]) {
        self.storages = storages
        self.info = info
    }
}


// MARK: - Content

extension StoragesConfiguration: Content { }
