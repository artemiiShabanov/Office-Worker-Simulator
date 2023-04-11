import Foundation

protocol WorkTaskProgramDelegate: AnyObject {
    func finished(success: Bool)
}

protocol WorkTaskProgram: Program, AnyObject {
    var delegate: WorkTaskProgramDelegate? { get set }
}
