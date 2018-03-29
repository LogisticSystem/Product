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
    
    func getAll() -> [Product] {
        return self.products.get()
    }
}


// MARK: - Service

extension ProductsService: Service { }
