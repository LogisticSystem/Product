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
}


// MARK: - Service

extension StoragesService: Service { }

