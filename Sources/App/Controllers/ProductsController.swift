import Vapor

struct ProductsController {
    
    private let routeGeneratorUrl = "http://localhost:8080/navigator/route"
    private let storagesUrl = "http://localhost:8080/storages"
}


// MARK: - Public methods

extension ProductsController {
    
    func cleanHandler(_ request: Request) throws -> [Product] {
        let productsService = try request.make(ProductsService.self)
        return productsService.clean()
    }
    
    func getAllHandler(_ request: Request) throws -> [Product] {
        let productsService = try request.make(ProductsService.self)
        return productsService.getAll()
    }
    
    func createProductHandler(_ request: Request) throws -> Future<Product> {
        var urlComponents = URLComponents(string: self.routeGeneratorUrl)
        
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
            return try response.content.decode(NavigatorRouteInfo.self).flatMap(to: Product.self) { routeInfo in
                let product = Product(source: routeInfo.source, destination: routeInfo.destination, route: routeInfo.storages, ownerId: nil)
                
                let productsService = try request.make(ProductsService.self)
                productsService.add(product)
                
                var urlComponents = URLComponents(string: self.storagesUrl)
                urlComponents?.path += "/" + routeInfo.source + "/products"
                
                guard let url = urlComponents?.string else { throw Abort(.badRequest) }
                let content = MultipleProducts(products: [product])
                
                return try request.make(Client.self).post(url, content: content).map(to: Product.self) { response in
                    return product
                }
            }
        }
    }
    
    func multipleChangeOwnerHandler(_ request: Request) throws -> Future<MultipleProducts> {
        return try request.content.decode(MultipleProducts.self).map(to: MultipleProducts.self) { multipleProducts in
            let ownerId = try request.parameter(String.self)
            
            let productsService = try request.make(ProductsService.self)
            let products = productsService.changeOwner(ownerId, forProducts: multipleProducts.products)
            
            return MultipleProducts(products: products)
        }
    }
    
    func multipleDeleteOwnerHandler(_ request: Request) throws -> Future<MultipleProducts> {
        return try request.content.decode(MultipleProducts.self).map(to: MultipleProducts.self) { multipleProducts in
            let productsService = try request.make(ProductsService.self)
            let products = productsService.changeOwner(nil, forProducts: multipleProducts.products)
            
            return MultipleProducts(products: products)
        }
    }
}


// MARK: - RouteCollection

extension ProductsController: RouteCollection {
    
    func boot(router: Router) throws {
        let productsController = router.grouped("products")
        productsController.put(use: cleanHandler)
        productsController.get(use: getAllHandler)
        productsController.get("new", use: createProductHandler)
        productsController.put("owner", String.parameter, use: multipleChangeOwnerHandler)
        productsController.put("owner", use: multipleDeleteOwnerHandler)
    }
}
