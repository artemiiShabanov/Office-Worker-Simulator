import Foundation

enum GameMode {
    case employee
    case boss
}

class Game {
    private let mode: GameMode = .employee
    private let computer: Computer
    
    init(computer: Computer) {
        self.computer = computer
    }
    
    func start() {
        computer.startup(program: StubWorkTaskProgram())
    }
}

extension Game: WorkTaskProgramDelegate {
    func taskFinished(success: Bool) {
        
    }
}
