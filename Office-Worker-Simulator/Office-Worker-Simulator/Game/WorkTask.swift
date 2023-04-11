import UIKit

enum Difficulty: Int, CaseIterable {
    case intern = 0
    case employee
    case manager
    case CEO
    
    var name: String {
        switch self {
        case .intern:
            return NSLocalizedString("difficulty_name_intern", comment: "")
        case .employee:
            return NSLocalizedString("difficulty_name_employee", comment: "")
        case .manager:
            return NSLocalizedString("difficulty_name_manager", comment: "")
        case .CEO:
            return NSLocalizedString("difficulty_name_CEO", comment: "")
        }
    }
    
    var next: Difficulty {
        switch self {
        case .intern:
            return .employee
        case .employee:
            return .manager
        case .manager:
            return .CEO
        case .CEO:
            return .CEO
        }
    }
}

enum WorkTask: String, CaseIterable {
    case typing
    case clicks
    case fileSort
}

extension WorkTask {
    func compile(with difficulty: Difficulty) -> WorkTaskProgram {
        switch self {
        case .typing:
            return TypingWorkTaskProgram(difficulty: difficulty)
        case .clicks:
            return ClickingWorkTaskProgram(difficulty: difficulty)
        case .fileSort:
            return SortingWorkTaskProgram(difficulty: difficulty)
        }
    }
    
    var description: String {
        switch self {
        case .typing:
            return NSLocalizedString("worktask_description_typing", comment: "")
        case .clicks:
            return NSLocalizedString("worktask_description_clicks", comment: "")
        case .fileSort:
            return NSLocalizedString("worktask_description_fileSort", comment: "")
        }
    }
    
    var tutorial: [UIImage] {
        switch self {
        case .typing:
            return [
                UIImage(named: "typing/tutorial/tut_1")!,
                UIImage(named: "typing/tutorial/tut_2")!
            ]
        case .clicks:
            return [
                UIImage(named: "clicking/tutorial/tut_1")!,
                UIImage(named: "clicking/tutorial/tut_2")!
            ]
        case .fileSort:
            return [
                UIImage(named: "sorting/tutorial/tut_1")!,
                UIImage(named: "sorting/tutorial/tut_2")!
            ]
        }
    }
}
