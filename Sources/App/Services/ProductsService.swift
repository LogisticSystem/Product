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
