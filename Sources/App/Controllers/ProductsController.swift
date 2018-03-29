import Vapor

struct ProductsController { }


// MARK: - Public methods

extension ProductsController {
    
    func createProductHandler(_ request: Request) throws -> Future<Product> {
        var urlComponents = URLComponents(string: "http://localhost:8080/navigator/route")
        
        let query = try request.query.decode(ProductsCreateProductQuery.self)
        var queryItems: [URLQueryItem] = []
        if let source = query.source {
            let sourceQueryItem = URLQueryItem(name: "source", value: source)
            queryItems.append(sourceQueryItem)
        }
        if let destination = query.destination {
            let destinationQueryItem = URLQueryItem(name: "destination", value: destination)
            queryItems.append(destinationQueryItem)
        }
        
        urlComponents?.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = urlComponents?.string else { throw Abort(.badRequest) }
        
        return try request.make(Client.self).get(url).flatMap(to: Product.self) { response in
            return try response.content.decode(NavigatorRouteInfo.self).map(to: Product.self) { routeInfo in
                guard let source = routeInfo.storages.first else { throw Abort(.badRequest) }
                guard let destination = routeInfo.storages.last else { throw Abort(.badRequest) }
                
                let product = Product(source: source, destination: destination, route: routeInfo.storages, ownerId: nil)
                
                let productsService = try request.make(ProductsService.self)
                productsService.add(product)
                
                return product
            }
        }
    }
    
    func getAllHandler(_ request: Request) throws -> [Product] {
        let productsService = try request.make(ProductsService.self)
        return productsService.getAll()
    }
    
    func changeOwnerHandler(_ request: Request) throws -> Product {
        let productId = try request.parameter(String.self)
        let ownerId = try request.parameter(String.self)
        
        let productsService = try request.make(ProductsService.self)
        guard let product = productsService.changeOwner(ownerId, forProduct: productId) else { throw Abort(.badRequest) }
        
        return product
    }
    
    func deleteOwnerHandler(_ request: Request) throws -> Product {
        let productId = try request.parameter(String.self)
        let ownerId = try request.parameter(String.self)
        
        let productsService = try request.make(ProductsService.self)
        guard let tmpOwnerId = productsService.get(productId)?.ownerId, tmpOwnerId == ownerId else { throw Abort(.badRequest) }
        guard let product = productsService.changeOwner(nil, forProduct: productId) else { throw Abort(.badRequest) }
        
        return product
    }
}


// MARK: - RouteCollection

extension ProductsController: RouteCollection {
    
    func boot(router: Router) throws {
        let productsController = router.grouped("products")
        productsController.get("new", use: createProductHandler)
        productsController.get(use: getAllHandler)
        productsController.post(String.parameter, "owner", String.parameter, use: changeOwnerHandler)
        productsController.delete(String.parameter, "owner", String.parameter, use: deleteOwnerHandler)
    }
}
