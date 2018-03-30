import Vapor

final class NavigatorRouteInfo: Codable {
    
    let source: String
    let destination: String
    let storages: [String]
    
    init(source: String, destination: String, storages: [String]) {
        self.source = source
        self.destination = destination
        self.storages = storages
    }
}


// MARK: - Content

extension NavigatorRouteInfo: Content { }
