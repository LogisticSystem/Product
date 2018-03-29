import Vapor

final class ProductsService {
    
    private var products = SynchronizedValue([Product]())
}


// MARK: Public methods

extension ProductsService {
    
    func add(_ product: Product) {
        self.products.asyncSet { products in
            products.append(product)
        }
    }
    
    func get(_ productId: String) -> Product? {
        let products = self.products.get()
        guard let productIndex = products.index(where: { $0.id == productId}) else { return nil }
        
        return products[productIndex]
    }
    
    func getAll() -> [Product] {
        return self.products.get()
    }
    
    func changeOwner(_ ownerId: String?, forProduct productId: String) -> Product? {
        var product: Product? = nil
        self.products.syncSet { products in
            guard let productIndex = products.index(where: { $0.id == productId }) else { return }
            
            product = products[productIndex]
            product?.ownerId = ownerId
        }
        
        return product
    }
}


// MARK: - Service

extension ProductsService: Service { }
