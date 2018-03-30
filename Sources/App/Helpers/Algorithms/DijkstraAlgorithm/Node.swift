class Node {
    
    var visited: Bool
    var connections: [Connection]
    
    init() {
        self.visited = false
        self.connections = []
    }
}
