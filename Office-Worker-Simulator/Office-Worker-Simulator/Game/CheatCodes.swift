import Foundation

enum Cheatcode: Int, CaseIterable {
    static let length = 10
    case immortality
    case changeBG
    case changeDifficulty
    case taskTyping
    case taskSorting
    case taskClicking
    
    var command: String {
        switch self {
        case .immortality:
            return "OXOXXOXOXX"
        case .changeBG:
            return "XXXXXOOOOO"
        case .changeDifficulty:
            return "OXOXXXOOXO"
        case .taskTyping:
            return "OXOXXOXOXO"
        case .taskSorting:
            return "XOXOXXXXOO"
        case .taskClicking:
            return "OXXOXOOXXO"
        }
    }
}
