import Foundation

final private class StorageNode: Node {
    
    let name: String
    
    init(name: String) {
        self.name = name
        super.init()
    }
}

final class Navigator {
    
    private let nodes: [String : StorageNode]
    
    init(storagesConfiguration: StoragesConfiguration) {
        #if os(Linux)
            srandom(UInt32(time(nil)))
        #endif
        
        var nodes: [String : StorageNode] = [:]
        for storage in storagesConfiguration.storages {
            let storageNode = StorageNode(name: storage)
            nodes[storage] = storageNode
        }
        
        for storageInfo in storagesConfiguration.info {
            guard let storage = nodes[storageInfo.name] else { continue }
            for connection in storageInfo.connections {
                guard let node = nodes[connection.name] else { continue }
                
                let connection = Connection(to: node, weight: connection.weight)
                storage.connections.append(connection)
            }
        }
        
        self.nodes = nodes
    }
}


// MARK: - Public methods

extension Navigator {
    
    func randomStorage(notEqual storage: String? = nil) -> String {
        let keys = Array(self.nodes.keys)
        
        var random: String = ""
        repeat {
            let index = generateRandom(max: keys.count)
            random = keys[index]
        } while(storage == random)
        
        return random
    }
    
    func shortestPath(source: String, destination: String) -> [String]? {
        guard let sourceNode = self.nodes[source] else { return nil }
        guard let destinationNode = self.nodes[destination] else { return nil }
        guard let path = DijkstraAlgorithm.shortestPath(source: sourceNode, destination: destinationNode) else { return nil }
        
        let result = path.array.reversed().compactMap { $0 as? StorageNode }.map { $0.name }
        return result
    }
}


// MARK: - Private methods

private extension Navigator {
    
    func generateRandom(max: Int) -> Int {
        #if os(Linux)
            return Int(random() % max)
        #else
            return Int(arc4random_uniform(UInt32(max)))
        #endif
    }
    
}
