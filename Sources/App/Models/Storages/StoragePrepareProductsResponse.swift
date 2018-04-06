import Vapor

final class StoragePrepareProductsResponse: Codable {
    
    // MARK: - Публичные свойства
    
    /// Товары
    var products: [StorageProduct]
    
    
    // MARK: - Инициализация
    
    init(products: [StorageProduct]) {
        self.products = products
    }
}


// MARK: - Content

extension StoragePrepareProductsResponse: Content { }
