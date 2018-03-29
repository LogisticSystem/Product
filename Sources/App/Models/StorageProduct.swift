import Vapor

final class StorageProduct: Codable {
    
    var id: String
    var source: String
    var destination: String
    var route: [String]
    
    init(id: String, source: String, destination: String, route: [String]) {
        self.id = id
        self.source = source
        self.destination = destination
        self.route = route
    }
}


// MARK: - Content

extension StorageProduct: Content { }
