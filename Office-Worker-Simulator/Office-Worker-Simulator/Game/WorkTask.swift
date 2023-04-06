import Foundation

enum WorkTaskPrefType {
    case toggle(Bool)
    case bounds(min: Int, max: Int)
    case `enum`(strings: [String])
}

struct WorkTaskPref {
    let type: WorkTaskPrefType
    let name: String
}

typealias WorkTaskPrefs = [String: WorkTaskPref]

enum WorkTask: String, CaseIterable {
    case typing
    case buttons
    case fileSort
}

extension WorkTask {
    var prefsList: WorkTaskPrefs {
        [:]
    }
    
    func compile(with prefs: WorkTaskPrefs) -> Program {
        StubWorkTaskProgram()
    }
}
