import Vapor

final class Storages: Codable  {
    
    let storages: [String]
    let info: [Storage]
    
    init(storages: [String], info: [Storage]) {
        self.storages = storages
        self.info = info
    }
}


// MARK: - Content

extension Storages: Content { }
