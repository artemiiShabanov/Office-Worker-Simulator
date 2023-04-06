import Foundation

struct WorkDay {
    private let tasks: [WorkTask]
    private var currentTaskIndex = -1
    
    init() {
        tasks = WorkTask.allCases.shuffled()
    }
    
    mutating func next() -> WorkTask {
        currentTaskIndex += 1
        return tasks[currentTaskIndex]
    }
    
}
