import UIKit

private let textAttributes: [NSAttributedString.Key : Any] = [
    .foregroundColor : UIColor.darkText,
    .font: UIFont.systemFont(ofSize: 30, weight: .medium)
]

class OldTwoButtonKeyboard: Keybaord {
    private lazy var keyboardView: TwoButtonKeyboardView = {
        let view = TwoButtonKeyboardView(designImage: Images.Computer.oldKeyboard, buttonImage: Images.Computer.oldKey)
        view.leftButton.addTarget(self, action: #selector(leftTap), for: .touchDown)
        configure(key: view.leftButton)
        view.rightButton.addTarget(self, action: #selector(rightTap), for: .touchDown)
        configure(key: view.rightButton)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var onTap: Closure<KeyType>?
    
    func render(in view: UIView) {
        view.addSubview(keyboardView)
        NSLayoutConstraint.activate([
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func `switch`(keys: [Key]) {
        guard keys.count == 2, let left = keys.first(where: { $0.type == .left }), let right = keys.first(where: { $0.type == .right }) else { return }
        keyboardView.setup(symbols: [left.symbol, right.symbol], textAttributes: textAttributes)
    }
}

// MARK: - Private

private extension OldTwoButtonKeyboard {
    @objc func leftTap() {
        onTap?(.left)
    }
    @objc func rightTap() {
        onTap?(.right)
    }
    private func configure(key: UIButton) {
        key.contentHorizontalAlignment = .left
        key.contentVerticalAlignment = .top
        key.titleEdgeInsets = UIEdgeInsets(top: 20.0, left: 32.0, bottom: 0.0, right: 0.0)
    }
}
