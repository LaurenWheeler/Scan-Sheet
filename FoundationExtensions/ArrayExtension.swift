extension Array {
    func extractFrom(startIndex : Int, to endIndex : Int) -> [Element] {
        let end = endIndex < self.count ? endIndex : (self.count > 0 ? self.count : 0)
        let start = startIndex > -1 ? startIndex : 0
        var newArray : [Element] = []
        for i in start..<end {
            newArray.append(self[i])
        }
        return newArray
    }
}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
