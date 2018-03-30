extension Array {
    
    /// Получить первые n элементов массива
    func elements(count: Int) -> Array<Element> {
        guard count < self.count else { return self }
        return Array(self[..<count])
    }
}
