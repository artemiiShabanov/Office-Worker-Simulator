import Foundation

class Preferences {
    private let ud = UserDefaults.standard
    
    static let shared = Preferences()
    private init() { }
    
    var difficulty: Difficulty {
        get {
            Difficulty(rawValue: ud.integer(forKey: "difficulty"))!
        }
        set {
            ud.set(newValue.rawValue, forKey: "difficulty")
        }
    }
    
    var completedDifficulties: Set<Difficulty> {
        get {
            Set((ud.array(forKey: "completedDifficulties") as? [Int])?.map { Difficulty(rawValue: $0)! } ?? [])
        }
        set {
            ud.set(newValue.map { $0.rawValue }, forKey: "completedDifficulties")
        }
    }
    
    func beat(difficulty: Difficulty) {
        var set = Preferences.shared.completedDifficulties
        set.insert(difficulty)
        Preferences.shared.completedDifficulties = set
    }
    
    var welcomed: Bool {
        get {
            ud.bool(forKey: "welcomed")
        }
        set {
            ud.set(newValue, forKey: "welcomed")
        }
    }
    
    var signed: Bool {
        get {
            ud.bool(forKey: "signed")
        }
        set {
            ud.set(newValue, forKey: "signed")
        }
    }
    
    var officeStyle: OfficeStyle {
        get {
            OfficeStyle(rawValue: ud.integer(forKey: "office_style"))!
        }
        set {
            ud.set(newValue.rawValue, forKey: "office_style")
        }
    }
    
    var immortal: Bool {
        get {
            ud.bool(forKey: "immortal")
        }
        set {
            ud.set(newValue, forKey: "immortal")
        }
    }
    
    var watchedTutorials: Set<WorkTask> {
        get {
            Set((ud.array(forKey: "watchedTutorials") as? [String])?.map { WorkTask(rawValue: $0)! } ?? [])
        }
        set {
            ud.set(newValue.map { $0.rawValue }, forKey: "watchedTutorials")
        }
    }
    
    func watchTutorial(for workTask: WorkTask) {
        var set = Preferences.shared.watchedTutorials
        set.insert(workTask)
        Preferences.shared.watchedTutorials = set
    }
}
