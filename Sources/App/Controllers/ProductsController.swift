import Vapor

struct ProductsController {
    
    // MARK: - Приватные свойства
    
    /// Модуль "Навигатор"
    private let navigatorUrl = "http://localhost:8080/navigator"
    /// Модуль "Склад"
    private let storagesUrl = "http://localhost:8080/storages"
}


// MARK: - Публичные методы

extension ProductsController {
    
    /// Очистка массива товаров
    func cleanHandler(_ request: Request) throws -> [Product] {
        let productsService = try request.make(ProductsService.self)
        return productsService.clean()
    }
    
    /// Получение списка товаров
    func getAllHandler(_ request: Request) throws -> [Product] {
        let productsService = try request.make(ProductsService.self)
        return productsService.getAll()
    }
    
    /// Создание товара
    func createProductHandler(_ request: Request) throws -> Future<Product> {
        
        // Формирование запроса на создание маршрута
        var urlComponents = URLComponents(string: self.navigatorUrl + "/route")
        
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
        
        // Отправка запроса на создание маршрута
        return try request.make(Client.self).get(url).flatMap(to: Product.self) { response in
            return try response.content.decode(NavigatorRouteInfo.self).flatMap(to: Product.self) { routeInfo in
                
                // Создание товара
                let product = Product(source: routeInfo.source, destination: routeInfo.destination, route: routeInfo.storages, ownerId: nil)
                
                // Сохранение товара
                let productsService = try request.make(ProductsService.self)
                productsService.add(product)
                
                // Формирование запроса на отправку товара складу
                var urlComponents = URLComponents(string: self.storagesUrl)
                urlComponents?.path += "/\(routeInfo.source)/products"
                
                guard let url = urlComponents?.string else { throw Abort(.badRequest) }
                
                // Отправка товара складу
                let content = MultipleProducts(products: [product])
                return try request.make(Client.self).post(url, content: content).map(to: Product.self) { response in
                    return product
                }
            }
        }
    }
    
    /// Изменение владельца для товаров
    func multipleChangeOwnerHandler(_ request: Request) throws -> Future<MultipleProducts> {
        return try request.content.decode(MultipleProducts.self).map(to: MultipleProducts.self) { multipleProducts in
            let ownerId = try request.parameter(String.self)
            
            let productsService = try request.make(ProductsService.self)
            let products = productsService.changeOwner(ownerId, forProducts: multipleProducts.products)
            
            return MultipleProducts(products: products)
        }
    }
    
    /// Удаление владельца для товаров
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
