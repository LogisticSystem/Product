import Vapor

struct NavigatorController {
    
    private let storagesUrl = "http://localhost:8080/storages.json"
}


// MARK: - Public methods

extension NavigatorController {
    
    func loadConfigsHandler(_ request: Request) throws -> Future<Storages> {
        return try request.make(Client.self).get(self.storagesUrl).flatMap(to: Storages.self) { response in
            return try response.content.decode(Storages.self)
        }
    }
    
    func createRouteHandler(_ request: Request) throws -> Future<RouteInfo> {
        return try loadConfigsHandler(request).map(to: RouteInfo.self) { storages in
            let navigator = Navigator(storages: storages)
            
            let query = try request.query.decode(RouteQuery.self)
            let source = query.source ?? navigator.randomStorage()
            let destination = query.destination ?? navigator.randomStorage(notEqual: source)
            
            guard let storages = navigator.shortestPath(source: source, destination: destination) else { throw Abort(.badRequest) }
            
            let routeInfo = RouteInfo(storages: storages)
            return routeInfo
        }
    }
}


// MARK: - RouteCollection

extension NavigatorController: RouteCollection {
    
    func boot(router: Router) throws {
        let navigatorController = router.grouped("navigator")
        navigatorController.get("configs", use: loadConfigsHandler)
        navigatorController.get("route", use: createRouteHandler)
    }
}
