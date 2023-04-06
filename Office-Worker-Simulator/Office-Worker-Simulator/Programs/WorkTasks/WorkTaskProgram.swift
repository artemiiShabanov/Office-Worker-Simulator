import Foundation

protocol WorkTaskProgramDelegate {
    func taskFinished(success: Bool)
}

protocol WorkTaskProgram: Program {
    func set(delegate: WorkTaskProgramDelegate)
}
