import UIKit

protocol WelcomeProgramDelegate: AnyObject {
    func signed()
    func declined()
}

class WelcomeProgram: Program {
    private enum Page: CaseIterable {
        case welcome
        case terms
        case sign
    }
    
    private lazy var label = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .left
        label.contentMode = .top
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var view = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])
        return view
    }()
    
    weak var delegate: WelcomeProgramDelegate?
    var keys: [Key] = [
        .init(symbol: NSLocalizedString("yes", comment: "").uppercased(), type: .left),
        .init(symbol: NSLocalizedString("no", comment: "").uppercased(), type: .right)
    ]
    
    private var page = Page.welcome {
        didSet {
            switch page {
            case .welcome:
                label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
                label.text = NSLocalizedString("welcome_message", comment: "") + " " + NSLocalizedString("yes", comment: "").uppercased() + "/" + NSLocalizedString("no", comment: "").uppercased()
            case .terms:
                label.font = .monospacedSystemFont(ofSize: 1, weight: .regular)
                label.text = Texts.lorem + Texts.lorem + Texts.lorem
            case .sign:
                label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
                label.text = NSLocalizedString("sign_message", comment: "") + "\n\n" + NSLocalizedString("yes", comment: "").uppercased() + "/" + NSLocalizedString("no", comment: "").uppercased()
            }
        }
    }
    
    func render(in window: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            view.widthAnchor.constraint(equalTo: window.widthAnchor),
            view.heightAnchor.constraint(equalTo: window.heightAnchor)
        ])
        page = .welcome
    }
    
    func react(toInput key: KeyType) {
        switch key {
        case .left:
            switch page {
            case .welcome:
                page = .terms
            case .terms:
                page = .sign
            case .sign:
                Preferences.shared.welcomed = true
                Preferences.shared.signed = true
                delegate?.signed()
            }
        case .right:
            Preferences.shared.signed = false
            Preferences.shared.welcomed = true
            delegate?.declined()
        }
    }
    
}
