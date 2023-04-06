import UIKit

private let textAttributes: [NSAttributedString.Key : Any] = [
    .strokeColor : Colors.oldKey,
    .foregroundColor : UIColor.darkText,
    .strokeWidth : -3.0,
    .font: UIFont.systemFont(ofSize: 30, weight: .medium)
]

class OldTwoButtonKeyboard: Keybaord {
    private lazy var keyboardView: TwoButtonKeyboardView = {
        let view = TwoButtonKeyboardView(designImage: Images.oldKeyboard, buttonImage: Images.oldKey)
        view.leftButton.addTarget(self, action: #selector(leftTap), for: .touchUpInside)
        configure(key: view.leftButton)
        view.rightButton.addTarget(self, action: #selector(rightTap), for: .touchUpInside)
        configure(key: view.rightButton)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 2, height: 5)
        view.layer.shadowRadius = 10
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
        
        keyboardView.setup(symbols: ["0", "Ctrl"], textAttributes: textAttributes)
    }
    
    func `switch`(keys: [Key]) {
        guard keys.count == 2, keys.contains(where: { $0.type == .left }), keys.contains(where: { $0.type == .right }) else { return }
        keyboardView.setup(symbols: keys.map(\.symbol), textAttributes: textAttributes)
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
