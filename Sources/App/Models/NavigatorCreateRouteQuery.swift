struct NavigatorCreateRouteQuery: Decodable {
    
    // MARK: - Публичные свойства
    
    /// Начальная точка маршрута
    var source: String?
    /// Конечная точка маршрута
    var destination: String?
}
