import Foundation
import FluentSQLite
import Vapor

final class Product: Codable {
    
    var id: UUID?
    var source: String
    var destination: String
    var route: String
    var ownerId: String?
    
    init(source: String, destination: String, route: String, ownerId: String?) {
        self.source = source
        self.destination = destination
        self.route = route
        self.ownerId = ownerId
    }
}


// MARK: - SQLiteUUIDModel

extension Product: SQLiteUUIDModel {
    static let idKey: IDKey = \Product.id
}


// MARK: - Migration

extension Product: Migration { }


// MARK: - Content

extension Product: Content { }
