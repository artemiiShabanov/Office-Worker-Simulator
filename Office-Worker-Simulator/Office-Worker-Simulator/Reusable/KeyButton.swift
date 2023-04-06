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
        animateScale(to: 0.95, duration: 0.05)
    }
    override func unHighlight() {
        Haptics.shared.play(type: .soft)
        animateScale(to: 1, duration: 0.05)
    }
}

// MARK: - Private

private extension KeyButton {
    func animateScale(to scale: CGFloat, duration: TimeInterval) {
        UIView.animate(
            withDuration:
            duration,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
               self.transform = .init(scaleX: scale, y: scale)
            }, completion: nil
        )
    }
}
