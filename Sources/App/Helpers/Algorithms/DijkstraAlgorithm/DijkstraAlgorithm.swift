final class DijkstraAlgorithm {
    
    static func shortestPath(source: Node, destination: Node) -> Path? {
        var frontier: [Path] = [] {
            didSet {
                frontier.sort { return $0.cumulativeWeight < $1.cumulativeWeight } // the frontier has to be always ordered
            }
        }
        
        frontier.append(Path(to: source)) // the frontier is made by a path that starts nowhere and ends in the source
        
        while !frontier.isEmpty {
            let cheapestPathInFrontier = frontier.removeFirst() // getting the cheapest path available
            guard !cheapestPathInFrontier.node.visited else { continue } // making sure we haven't visited the node already
            
            if cheapestPathInFrontier.node === destination {
                return cheapestPathInFrontier // found the cheapest path 😎
            }
            
            cheapestPathInFrontier.node.visited = true
            
            for connection in cheapestPathInFrontier.node.connections where !connection.to.visited { // adding new paths to our frontier
                frontier.append(Path(to: connection.to, via: connection, previousPath: cheapestPathInFrontier))
            }
        }
        
        return nil // we didn't find a path 😣
    }
}
