import Foundation

struct Queue<T> {
    private var elements: [T] = []
    
    var isEmpty: Bool { elements.isEmpty }
    var peek: T? { elements.first }
    mutating func enqueue(_ value: T) {
        elements.append(value)
    }
    mutating func dequeue() -> T? {
        isEmpty ? nil : elements.removeFirst()
    }
}
