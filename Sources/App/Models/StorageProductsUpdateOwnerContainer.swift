import Vapor

final class StorageProductsUpdateOwnerContainer: Codable {
    
    // MARK: - Публичные свойства
    
    /// Товары
    var products: [StorageProduct]
    
    
    // MARK: - Инициализация
    
    init(products: [StorageProduct]) {
        self.products = products
    }
}


// MARK: - Content

extension StorageProductsUpdateOwnerContainer: Content { }
