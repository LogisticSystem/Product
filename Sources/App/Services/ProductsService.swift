import Vapor

final class ProductsService {
    
    // MARK: - Приватные свойства
    
    /// Товары
    private var products = SynchronizedValue([Product]())
}


// MARK: - Публичные методы

extension ProductsService {
    
    /// Очистка данных
    func clean() -> [Product] {
        let products: [Product] = []
        self.products.syncSet { tmpProducts in
            tmpProducts = []
        }
        
        return products
    }
    
    /// Получение всех товаров
    func getAll() -> [Product] {
        return self.products.get()
    }
    
    /// Получение товара
    func get(_ productId: String) -> Product? {
        let products = self.products.get()
        guard let productIndex = products.index(where: { $0.id == productId}) else { return nil }
        
        return products[productIndex]
    }
    
    /// Добавление товара
    func add(_ product: Product) {
        self.products.asyncSet { products in
            products.append(product)
        }
    }
    
    /// Изменение владельца для группы товаров
    func changeOwner(_ ownerId: String?, forProducts products: [Product]) -> [Product] {
        var changedProducts: [Product] = []
        self.products.syncSet { tmpProducts in
            for product in products {
                guard let productIndex = tmpProducts.index(where: { $0.id == product.id }) else { continue }
                
                let tmpProduct = tmpProducts[productIndex]
                tmpProduct.route = product.route
                tmpProduct.ownerId = ownerId
                
                changedProducts.append(tmpProduct)
            }
        }
        
        return changedProducts
    }
}


// MARK: - Service

extension ProductsService: Service { }
