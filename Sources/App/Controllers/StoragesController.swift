import Vapor

struct StoragesController {
    
    private let configsUrl = "http://localhost:8080/storages.json"
}


// MARK: - Public methods

extension StoragesController {
    
    func configureHandler(_ request: Request) throws -> Future<[Storage]> {
        return try request.make(Client.self).get(self.configsUrl).flatMap(to: [Storage].self) { response in
            return try response.content.decode(StoragesConfiguration.self).map(to: [Storage].self) { storagesConfiguration in
                let storagesService = try request.make(StoragesService.self)
                let storages = storagesService.configure(with: storagesConfiguration)
                
                return storages
            }
        }
    }
    
    func getAllHandler(_ request: Request) throws -> [Storage] {
        let storagesService = try request.make(StoragesService.self)
        return storagesService.getAll()
    }
    
    func recieveProductsHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.content.decode(RecievedProducts.self).flatMap(to: HTTPStatus.self) { recievedProducts in
            var urlComponents = URLComponents(string: "http://localhost:8080/products/owner")
            
            let storageId = try request.parameter(String.self)
            urlComponents?.path += "/" + "storage-" + storageId
            
            guard let url = urlComponents?.string else { throw Abort(.badRequest) }
            let content = StorageProductsUpdateOwnerContainer(products: recievedProducts.products)
            return try request.make(Client.self).put(url, content: content).flatMap(to: HTTPStatus.self) { response in
                return try response.content.decode(StorageProductsUpdateOwnerContainer.self).map(to: HTTPStatus.self) { updatedProducts in
                    let storagesService = try request.make(StoragesService.self)
                    storagesService.put(updatedProducts.products, inStorage: storageId)
                    
                    return .ok
                }
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
    }
}
