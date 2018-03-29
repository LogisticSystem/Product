import Vapor

final class RouteInfo: Codable {
    
    let storages: [String]
    
    init(storages: [String]) {
        self.storages = storages
    }
}


// MARK: - Content

extension RouteInfo: Content { }
