import Foundation
import Vapor

final class Product: Codable {
    
    var id: String
    var source: String
    var destination: String
    var route: [String]
    var ownerId: String?
    
    init(id: String = UUID().uuidString, source: String, destination: String, route: [String], ownerId: String?) {
        self.id = id
        self.source = source
        self.destination = destination
        self.route = route
        self.ownerId = ownerId
    }
}


// MARK: - Content

extension Product: Content { }
