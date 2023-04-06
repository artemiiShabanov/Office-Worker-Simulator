import UIKit

enum KeyType {
    case left
    case right
}

struct Key {
    let symbol: String
    let type: KeyType
}

protocol Keybaord {
    var onTap: Closure<KeyType>? { get set }
    func render(in view: UIView)
    func `switch`(keys: [Key])
}
