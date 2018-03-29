import Vapor

final class StoragesService {
    
    private var storages = SynchronizedValue([Storage]())
}


// MARK: - Public methods

extension StoragesService {
    
    func configure(with storagesConfiguration: StoragesConfiguration) -> [Storage] {
        let storages = storagesConfiguration.storages.map { Storage(id: $0, products: []) }
        self.storages.syncSet { tmpStorages in
            tmpStorages = storages
        }
        
        return storages
    }
    
    func getAll() -> [Storage] {
        return self.storages.get()
    }
    
    func put(_ products: [StorageProduct], inStorage storageId: String) {
        self.storages.syncSet { storages in
            guard let storageIndex = storages.index(where: { $0.id == storageId }) else { return }
            storages[storageIndex].products.append(contentsOf: products)
        }
    }
    
    func getProducts(from storageId: String, to storagesIds: [String]?, count: Int?) -> [StorageProduct] {
        var products: [StorageProduct] = []
        self.storages.syncSet { storages in
            guard let storageIndex = storages.index(where: { $0.id == storageId }) else { return }
            let storage = storages[storageIndex]
            
            var tmp: [String : [StorageProduct]] = [:]
            for product in storage.products {
                guard let nextPointId = product.route.first else { continue }
                if let storagesIds = storagesIds {
                    guard storagesIds.contains(nextPointId) || storagesIds.isEmpty else { continue }
                }
                
                if tmp[nextPointId] == nil {
                    tmp[nextPointId] = []
                }
                
                tmp[nextPointId]?.append(product)
            }
            
            guard let result = tmp.max(by: { $0.value.count < $1.value.count }) else { return }
            if let count = count {
                products = result.value.elements(count: count)
            } else {
                products = result.value
            }
            
            for product in products {
                guard let productIndex = storage.products.index(where: { $0.id == product.id }) else { continue }
                storage.products.remove(at: productIndex)
            }
        }
        
        return products
    }
}


// MARK: - Service

extension StoragesService: Service { }
