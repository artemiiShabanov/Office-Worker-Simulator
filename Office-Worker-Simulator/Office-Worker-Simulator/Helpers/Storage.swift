import Foundation

class Preferences {
    private let ud = UserDefaults.standard
    static let shared = Preferences()
    private init() { }
    
    var beatenGame: Bool {
        get {
            ud.bool(forKey: "beaten_game")
        }
        set {
            ud.set(newValue, forKey: "beaten_game")
        }
    }
    
    func prefs(for task: WorkTask) -> WorkTaskPrefs? {
        ud.dictionary(forKey: "task_\(task.rawValue)") as? Dictionary<String, WorkTaskPref>
    }
    func prefs(set prefs: WorkTaskPrefs, for task: WorkTask) {
        ud.set(prefs, forKey: "task_\(task.rawValue)")
    }
}
