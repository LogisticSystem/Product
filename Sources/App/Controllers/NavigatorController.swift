import Vapor

struct NavigatorController {
    
    private let storagesUrl = "http://localhost:8080/storages.json"
}


// MARK: - Public methods

extension NavigatorController {
    
    func loadConfigsHandler(_ request: Request) throws -> Future<StoragesConfiguration> {
        return try request.make(Client.self).get(self.storagesUrl).flatMap(to: StoragesConfiguration.self) { response in
            return try response.content.decode(StoragesConfiguration.self)
        }
    }
    
    func createRouteHandler(_ request: Request) throws -> Future<NavigatorRouteInfo> {
        return try loadConfigsHandler(request).map(to: NavigatorRouteInfo.self) { storagesConfiguration in
            let navigator = Navigator(storagesConfiguration: storagesConfiguration)
            
            let query = try request.query.decode(NavigatorCreateRouteQuery.self)
            let source = query.source ?? navigator.randomStorage()
            let destination = query.destination ?? navigator.randomStorage(notEqual: source)
            
            guard let storages = navigator.shortestPath(source: source, destination: destination) else { throw Abort(.badRequest) }
            
            let routeInfo = NavigatorRouteInfo(storages: storages)
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
