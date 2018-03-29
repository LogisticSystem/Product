final class Connection {
    
    let to: Node
    let weight: Int
    
    init(to node: Node, weight: Int) {
        assert(weight >= 0, "weight has to be equal or greater than zero")
        
        self.to = node
        self.weight = weight
    }
}
