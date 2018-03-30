import Foundation

final private class StorageNode: Node {
    
    // MARK: - Публичные свойства
    
    /// Название склада
    let name: String
    
    
    // MARK: - Инициализация
    
    init(name: String) {
        self.name = name
        super.init()
    }
}

final class Navigator {
    
    // MARK: - Приватные свойства
    
    /// Узлы
    private let nodes: [String : StorageNode]
    
    
    // MARK: - Инициализация
    
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


// MARK: - Публичные методы

extension Navigator {
    
    /// Получение случайного склада
    func randomStorage(notEqual storage: String? = nil) -> String {
        let keys = Array(self.nodes.keys)
        
        var random: String = ""
        repeat {
            let index = generateRandom(max: keys.count)
            random = keys[index]
        } while(storage == random)
        
        return random
    }
    
    /// Получение пути от точки до точки
    func shortestPath(source: String, destination: String) -> NavigatorRouteInfo? {
        guard let sourceNode = self.nodes[source] else { return nil }
        guard let destinationNode = self.nodes[destination] else { return nil }
        guard let path = DijkstraAlgorithm.shortestPath(source: sourceNode, destination: destinationNode) else { return nil }
        
        let storages = path.array.reversed().compactMap { $0 as? StorageNode }
        guard let source = storages.first?.name, let destination = storages.last?.name else { return nil }
        
        var storagesInfo: [String] = []
        for (index, storage) in storages.enumerated() {
            guard index != 0 else {
                storagesInfo.append("\(storage.name)|0")
                continue
            }
            
            let previousStorage = storages[index - 1]
            guard let connectedStorageIndex = previousStorage.connections.index(where: { connection in
                guard let storageNode = connection.to as? StorageNode else { return false }
                return storageNode.name == storage.name
            }) else { continue }
            
            let weight = previousStorage.connections[connectedStorageIndex].weight
            storagesInfo.append("\(storage.name)|\(weight)")
        }
        
        let routeInfo = NavigatorRouteInfo(source: source, destination: destination, storages: storagesInfo)
        return routeInfo
    }
}


// MARK: - Приватные методы

private extension Navigator {
    
    /// Генерация случайного числа
    func generateRandom(max: Int) -> Int {
        #if os(Linux)
            return Int(random() % max)
        #else
            return Int(arc4random_uniform(UInt32(max)))
        #endif
    }
    
}
