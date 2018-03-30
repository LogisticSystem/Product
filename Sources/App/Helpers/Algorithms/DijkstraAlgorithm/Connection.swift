final class Connection {
    
    // MARK: - Публичные свойства
    
    let to: Node
    let weight: Int
    
    
    // MARK: - Инициализация
    
    init(to node: Node, weight: Int) {
        assert(weight >= 0, "weight has to be equal or greater than zero")
        
        self.to = node
        self.weight = weight
    }
}
