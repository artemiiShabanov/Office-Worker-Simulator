import UIKit

protocol Program {
    var keys: [Key] { get }
    func render(in window: UIView)
    func react(toInput key: KeyType)
}
