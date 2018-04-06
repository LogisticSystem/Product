import Vapor

struct StoragesController {
    
    /// Настройки
    private let configsUrl = "http://localhost:8080/storages.json"
    /// Модуль "Товар"
    private let productsUrl = "http://localhost:8080/products"
}


// MARK: - Публичные методы

extension StoragesController {
    
    /// Настройка
    func configureHandler(_ request: Request) throws -> Future<[Storage]> {
        return try request.make(Client.self).get(self.configsUrl).flatMap(to: [Storage].self) { response in
            return try response.content.decode(StoragesConfiguration.self).map(to: [Storage].self) { storagesConfiguration in
                let storagesService = try request.make(StoragesService.self)
                let storages = storagesService.configure(with: storagesConfiguration)
                
                return storages
            }
        }
    }
    
    /// Получение списка складов
    func getAllHandler(_ request: Request) throws -> [Storage] {
        let storagesService = try request.make(StoragesService.self)
        return storagesService.getAll()
    }
    
    /// Получение товаров
    func recieveProductsHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.content.decode(RecievedProducts.self).flatMap(to: HTTPStatus.self) { recievedProducts in
            
            // Параметры запроса
            let storageId = try request.parameter(String.self)
            
            // Логирование
            let loggerService = try request.make(LoggerService.self)
            
            let storagesMessage = StoragesMessage(action: "storagesWillRecieve|message|log", products: recievedProducts.products, storageId: storageId, transportId: recievedProducts.transportId)
            try loggerService.log(storagesMessage)
            
            // Формирование запроса на обновление владельца товаров
            var urlComponents = URLComponents(string: self.productsUrl + "/owner")
            urlComponents?.path += "/storage-\(storageId)"
            
            guard let url = urlComponents?.string else { throw Abort(.badRequest, reason: "URL cannot construct with the storage identifier \(storageId).") }
            recievedProducts.products.forEach { product in
                if recievedProducts.transportId?.hasPrefix("car") ?? false {
                    product.route.removeAll()
                } else {
                    product.route.removeFirst()
                }
            }
            
            // Отправка запроса на обновление владельца товаров
            return try self.updateOwner(request, url: url, products: recievedProducts.products).map(to: HTTPStatus.self) { products in
                
                // Сортировка товаров
                var deliveredProducts: [StorageProduct] = []
                var newProducts: [StorageProduct] = []
                
                for product in products {
                    if product.route.isEmpty || product.destination == storageId {
                        deliveredProducts.append(product)
                    } else {
                        newProducts.append(product)
                    }
                }
                
                // Сохранение товаров в склад
                let storagesService = try request.make(StoragesService.self)
                storagesService.put(newProducts, inStorage: storageId)
                
                // Логирование
                let loggerService = try request.make(LoggerService.self)
                
                let storagesMessage = StoragesMessage(action: "storagesDidRecieve|message|log", products: products, storageId: storageId, transportId: recievedProducts.transportId)
                try loggerService.log(storagesMessage)
                
                if !deliveredProducts.isEmpty {
                    let storagesMessage = StoragesMessage(action: "storagesDidFinishDelivering|message|log", products: deliveredProducts, storageId: storageId, transportId: recievedProducts.transportId)
                    try loggerService.log(storagesMessage)
                }
                
                return .ok
            }
        }
    }
    
    /// Отправка товаров
    func prepareProductsHandler(_ request: Request) throws -> Future<StoragePrepareProductsResponse> {
        return try request.content.decode(StoragePrepareProductsRequest.self).flatMap(to: StoragePrepareProductsResponse.self) { prepareProductsRequest in
            
            // Параметры запроса
            let storageId = try request.parameter(String.self)
            
            // Логирование
            let loggerService = try request.make(LoggerService.self)
            
            let storagesMessage = StoragesMessage(action: "storagesWillSend|message|log", products: [], storageId: storageId, transportId: prepareProductsRequest.transportId)
            try loggerService.log(storagesMessage)
            
            // Подготовка товаров к отправке
            let storagesService = try request.make(StoragesService.self)
            let products = storagesService.getProducts(from: storageId, to: prepareProductsRequest.accessiblePoints, count: prepareProductsRequest.capacity)
            
            // Отправка запроса на обновление владельца товаров
            return try self.updateOwner(request, url: self.productsUrl + "/owner", products: products).map(to: StoragePrepareProductsResponse.self) { products in
                
                // Логирование
                let loggerService = try request.make(LoggerService.self)
                
                let storagesMessage = StoragesMessage(action: "storagesDidSend|message|log", products: products, storageId: storageId, transportId: prepareProductsRequest.transportId)
                try loggerService.log(storagesMessage)
                
                // Отправка товаров
                let prepareProductsResponse = StoragePrepareProductsResponse(products: products)
                return prepareProductsResponse
            }
        }
    }
}


// MARK: - Приватные методы

private extension StoragesController {
    
    /// Изменить владельца для группы товаров
    func updateOwner(_ request: Request, url: String, products: [StorageProduct]) throws -> Future<[StorageProduct]> {
        let content = StorageProductsUpdateOwnerContainer(products: products)
        return try request.make(Client.self).put(url, content: content).flatMap(to: [StorageProduct].self) { response in
            return try response.content.decode(StorageProductsUpdateOwnerContainer.self).map(to: [StorageProduct].self) { updatedProducts in
                return updatedProducts.products
            }
        }
    }
}


// MARK: - RouteCollection

extension StoragesController: RouteCollection {
    
    func boot(router: Router) throws {
        let storagesController = router.grouped("storages")
        storagesController.put(use: configureHandler)
        storagesController.get(use: getAllHandler)
        storagesController.post(String.parameter, "products", use: recieveProductsHandler)
        storagesController.post(String.parameter, "products", "prepare", use: prepareProductsHandler)
    }
}
