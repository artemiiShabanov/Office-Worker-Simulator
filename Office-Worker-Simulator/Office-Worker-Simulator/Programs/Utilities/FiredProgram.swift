import UIKit

protocol FiredProgramDelegate: AnyObject {
    func wantToRestart()
}

class FiredProgram: Program {
    private enum Page: CaseIterable {
        case fired
        case sorry
        case restart
    }
    private lazy var label = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .left
        label.contentMode = .top
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var view = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])
        return view
    }()
    
    weak var delegate: FiredProgramDelegate?
    var keys: [Key] = [
        .init(symbol: "←", type: .left),
        .init(symbol: "→", type: .right)
    ]
    private var page = Page.fired {
        didSet {
            switch page {
            case .fired:
                label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
                label.text = "☠️ \(NSLocalizedString("fired", comment: "")) ☠️"
            case .sorry:
                label.font = .monospacedSystemFont(ofSize: 8, weight: .regular)
                label.text = NSLocalizedString("fired_message", comment: "")
            case .restart:
                label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
                label.text = String(format: NSLocalizedString("fired_restart", comment: ""), 5 - counter)
            }
        }
    }
    private var counter = 0
    private let targetCount = 5
    
    func render(in window: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            view.widthAnchor.constraint(equalTo: window.widthAnchor),
            view.heightAnchor.constraint(equalTo: window.heightAnchor)
        ])
        page = .fired
    }
    
    func react(toInput key: KeyType) {
        switch key {
        case .left:
            counter = 0
            switch page {
            case .fired:
                break // no-op
            case .sorry:
                page = .fired
            case .restart:
                page = .sorry
            }
        case .right:
            switch page {
            case .fired:
                page = .sorry
            case .sorry:
                page = .restart
            case .restart:
                counter += 1
                label.text = String(format: NSLocalizedString("fired_restart", comment: ""), targetCount - counter)
                if counter >= targetCount {
                    delegate?.wantToRestart()
                }
            }
        }
    }
    
}
