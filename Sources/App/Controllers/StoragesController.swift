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
            
            // Формирование запроса на обновление владельца товаров
            var urlComponents = URLComponents(string: self.productsUrl + "/owner")
            
            let storageId = try request.parameter(String.self)
            urlComponents?.path += "/storage-\(storageId)"
            
            guard let url = urlComponents?.string else { throw Abort(.badRequest) }
            recievedProducts.products.forEach { $0.route.removeFirst() }
            
            // Отправка запроса на обновление владельца товаров
            return try self.updateOwner(request, url: url, products: recievedProducts.products).map(to: HTTPStatus.self) { updatedProducts in
                
                // Сохранение товаров в склад
                let storagesService = try request.make(StoragesService.self)
                
                let products = updatedProducts.filter { !$0.route.isEmpty }
                storagesService.put(products, inStorage: storageId)
                
                return .ok
            }
        }
    }
    
    /// Отправка товаров
    func prepareProductsHandler(_ request: Request) throws -> Future<StoragePrepareProductsResponse> {
        if request.http.mediaType == .json {
            
            // Извелечение данных из тела запроса
            return try request.content.decode(StoragePrepareProductsRequest.self).flatMap(to: StoragePrepareProductsResponse.self) { prepareProductsRequest in
                
                // Подготовка товаров к отправке
                let storageId = try request.parameter(String.self)
                
                let storagesService = try request.make(StoragesService.self)
                let products = storagesService.getProducts(from: storageId, to: prepareProductsRequest.accessiblePoints, count: prepareProductsRequest.capacity)
                
                // Отправка запроса на обновление владельца товаров
                return try self.updateOwner(request, url: self.productsUrl + "/owner", products: products).map(to: StoragePrepareProductsResponse.self) { products in
                    
                    // Отправка товаров
                    let prepareProductsResponse = StoragePrepareProductsResponse(products: products)
                    return prepareProductsResponse
                }
            }
        } else {
            
            // Подготовка товаров к отправке
            let storageId = try request.parameter(String.self)
            
            let storagesService = try request.make(StoragesService.self)
            let products = storagesService.getProducts(from: storageId)
            
            // Отправка запроса на обновление владельца товаров
            return try updateOwner(request, url: self.productsUrl + "/owner", products: products).map(to: StoragePrepareProductsResponse.self) { products in
                
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
