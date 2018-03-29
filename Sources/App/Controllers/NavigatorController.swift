import Vapor

struct NavigatorController {
    
    private let storagesUrl = "http://localhost:8080/storages.json"
}


// MARK: - Public methods

extension NavigatorController {
    
    func createRandomRouteHandler(_ request: Request) throws -> Future<RouteInfo> {
        return try request.make(Client.self).get(self.storagesUrl).flatMap(to: RouteInfo.self) { response in
            return try response.content.decode(Storages.self).map(to: RouteInfo.self) { storages in
                let navigator = Navigator(storages: storages)
                
                let source = navigator.randomStorage()
                let destination = navigator.randomStorage(notEqual: source)
                
                guard let storages = navigator.shortestPath(source: source, destination: destination) else {
                    throw Abort(.badRequest)
                }
                
                let routeInfo = RouteInfo(storages: storages)
                return routeInfo
            }
        }
    }
    
    func createRouteHandler(_ request: Request) throws -> Future<RouteInfo> {
        let source = try request.parameter(String.self)
        let destination = try request.parameter(String.self)
        return try request.make(Client.self).get(self.storagesUrl).flatMap(to: RouteInfo.self) { response in
            return try response.content.decode(Storages.self).map(to: RouteInfo.self) { storages in
                let navigator = Navigator(storages: storages)
                
                guard let storages = navigator.shortestPath(source: source, destination: destination) else {
                    throw Abort(.badRequest)
                }
                
                let routeInfo = RouteInfo(storages: storages)
                return routeInfo
            }
        }
    }
}


// MARK: - RouteCollection

extension NavigatorController: RouteCollection {
    
    func boot(router: Router) throws {
        let navigatorController = router.grouped("navigator")
        navigatorController.get("route", use: createRandomRouteHandler)
        navigatorController.get("route", String.parameter, String.parameter, use: createRouteHandler)
    }
}
