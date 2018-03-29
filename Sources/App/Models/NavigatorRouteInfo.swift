import Vapor

final class NavigatorRouteInfo: Codable {
    
    let storages: [String]
    
    init(storages: [String]) {
        self.storages = storages
    }
}


// MARK: - Content

extension NavigatorRouteInfo: Content { }
