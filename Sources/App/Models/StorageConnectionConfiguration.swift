import Vapor

final class StorageConnectionConfiguration: Codable {
    
    let name: String
    let weight: Int
    
    init(name: String, weight: Int) {
        self.name = name
        self.weight = weight
    }
}


// MARK: - Content

extension StorageConnectionConfiguration: Content { }
