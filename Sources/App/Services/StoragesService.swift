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
    
    func getProducts(from storageId: String, to storagesIds: [String]? = nil, count: Int? = nil) -> [StorageProduct] {
        var products: [StorageProduct] = []
        self.storages.syncSet { storages in
            
            // Получаем склад
            guard let storageIndex = storages.index(where: { $0.id == storageId }) else { return }
            let storage = storages[storageIndex]
            
            // Составляем словарь, в котором ключ - склад, а значение - массив товаров, которые необходимо доставить до этого склада
            var tmp: [String : [StorageProduct]] = [:]
            for product in storage.products {
                
                // Из маршрута получаем идентификатор следующей точки назначения
                guard let nextPointInfo = product.route.first, let _nextPointId = nextPointInfo.split(separator: "|").first else { continue }
                let nextPointId = String(_nextPointId)
                
                // Если точка не находится в запрашиваемом списке - пропускаем
                if let storagesIds = storagesIds {
                    guard storagesIds.contains(nextPointId) || storagesIds.isEmpty else { continue }
                }
                
                // Записываем товар в словарь
                if tmp[nextPointId] == nil {
                    tmp[nextPointId] = []
                }
                
                tmp[nextPointId]?.append(product)
            }
            
            // Получаем интересуемые нас значения
            if let storagesIds = storagesIds, !storagesIds.isEmpty {
                tmp = tmp.filter { storagesIds.contains($0.key) }
                products = tmp.flatMap { $0.value }
            } else {
                guard let result = tmp.max(by: { $0.value.count < $1.value.count }) else { return }
                products = result.value
            }
            
            // Оставляем запрашиваемое количество товаров
            if let count = count {
                products = products.elements(count: count)
            }
            
            // Удаляем отобранные товары из склада
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
