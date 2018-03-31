import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
func routes(_ router: Router) throws {
    
    // Navigator
    let navigatorController = NavigatorController()
    try router.register(collection: navigatorController)
    
    // Products
    let productsController = ProductsController()
    try router.register(collection: productsController)
    
    // Storages
    let storagesController = StoragesController()
    try router.register(collection: storagesController)
}
