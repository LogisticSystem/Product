import Vapor

final class Storage: Codable {
    
    let name: String
    let connections: [StorageConnection]
    
    init(name: String, connections: [StorageConnection]) {
        self.name = name
        self.connections = connections
    }
}


// MARK: - Content

extension Storage: Content { }
