import UIKit

struct StubWorkTaskProgram: Program {
    var keys: [Key] = []
    
    func render(in window: UIView) {
        window.addSubview(UIView())
    }
    
    func react(toInput key: KeyType) {
        // no-op
    }
}
