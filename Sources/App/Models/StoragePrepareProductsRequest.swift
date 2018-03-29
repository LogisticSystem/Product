import Vapor

final class StoragePrepareProductsRequest: Codable {
    
    var capacity: Int?
    var accessiblePoints: [String]?
    
    init(capacity: Int?, accessiblePoints: [String]?) {
        self.capacity = capacity
        self.accessiblePoints = accessiblePoints
    }
}


// MARK: - Content

extension StoragePrepareProductsRequest: Content { }
