import UIKit

class HighlightButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if oldValue == false && isHighlighted {
                highlight()
            } else if oldValue == true && !isHighlighted {
                unHighlight()
            }
        }
    }

    func highlight() { }

    func unHighlight() { }
}
