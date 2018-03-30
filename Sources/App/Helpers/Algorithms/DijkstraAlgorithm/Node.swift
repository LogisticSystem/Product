class Node {
    
    // MARK: - Публичные свойства
    
    var visited: Bool
    var connections: [Connection]
    
    
    // MARK: - Инициализация
    
    init() {
        self.visited = false
        self.connections = []
    }
}
