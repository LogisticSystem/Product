import Vapor

final class ProductsService {
    
    private var products = SynchronizedValue([Product]())
}


// MARK: - Public methods

extension ProductsService {
    
    func clean() -> [Product] {
        let products: [Product] = []
        self.products.syncSet { tmpProducts in
            tmpProducts = []
        }
        
        return products
    }
    
    func getAll() -> [Product] {
        return self.products.get()
    }
    
    func get(_ productId: String) -> Product? {
        let products = self.products.get()
        guard let productIndex = products.index(where: { $0.id == productId}) else { return nil }
        
        return products[productIndex]
    }
    
    func add(_ product: Product) {
        self.products.asyncSet { products in
            products.append(product)
        }
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
    
    func changeOwner(_ ownerId: String?, forProducts productsIds: [String]) -> [Product] {
        var changedProducts: [Product] = []
        self.products.syncSet { products in
            for productId in productsIds {
                guard let productIndex = products.index(where: { $0.id == productId }) else { continue }
                
                let product = products[productIndex]
                product.ownerId = ownerId
                
                changedProducts.append(product)
            }
        }
        
        return changedProducts
    }
}


// MARK: - Service

extension ProductsService: Service { }
