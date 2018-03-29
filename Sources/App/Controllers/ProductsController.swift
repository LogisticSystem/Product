import Vapor

struct ProductsController { }


// MARK: - Public methods

extension ProductsController {
    
    func createProductHandler(_ request: Request) throws -> Future<Product> {
        return try request.make(Client.self).get("http://localhost:8080/navigator/route").flatMap(to: Product.self) { response in
            return try response.content.decode(RouteInfo.self).flatMap(to: Product.self) { routeInfo in
                guard let source = routeInfo.storages.first else { throw Abort(.badRequest) }
                guard let destination = routeInfo.storages.last else { throw Abort(.badRequest) }
                let route = routeInfo.storages.joined(separator: " ")
                
                let product = Product(source: source, destination: destination, route: route, ownerId: nil)
                return product.save(on: request)
            }
        }
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[Product]> {
        return Product.query(on: request).all()
    }
}


// MARK: - RouteCollection

extension ProductsController: RouteCollection {
    
    func boot(router: Router) throws {
        let productsController = router.grouped("products")
        productsController.get("new", use: createProductHandler)
        productsController.get(use: getAllHandler)
    }
}
