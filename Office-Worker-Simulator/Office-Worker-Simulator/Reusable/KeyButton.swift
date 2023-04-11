import UIKit

class KeyButton: HighlightButton {
    init() {
        super.init(frame: .zero)
        adjustsImageWhenHighlighted = false
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func highlight() {
        Haptics.shared.play(type: .light)
        SoundPlayer.shared.play(sound: .oldKey)
        self.transform = .init(scaleX: 0.95, y: 0.95)
    }
    override func unHighlight() {
        Haptics.shared.play(type: .soft)
        self.transform = .identity
    }
}
