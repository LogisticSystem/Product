import Vapor

final class StorageInfoConfiguration: Codable {
    
    let name: String
    let connections: [StorageConnectionConfiguration]
    
    init(name: String, connections: [StorageConnectionConfiguration]) {
        self.name = name
        self.connections = connections
    }
}


// MARK: - Content

extension StorageInfoConfiguration: Content { }
