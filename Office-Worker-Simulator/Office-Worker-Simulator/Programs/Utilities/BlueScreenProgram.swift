import UIKit

protocol BlueScreenProgramDelegate: AnyObject {
    func fixed()
}

class BlueScreenProgram: Program {
    private lazy var view = {
        let view = UIView()
        view.backgroundColor = .blue
        let label = UILabel()
        view.addSubview(label)
        label.font = .monospacedSystemFont(ofSize: 4, weight: .regular)
        label.numberOfLines = 0
        label.text = Texts.blueScreen
        label.textColor = .white
        label.textAlignment = .left
        label.contentMode = .top
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
        ])
        return view
    }()
    
    weak var delegate: BlueScreenProgramDelegate?
    var keys: [Key] = [
        .init(symbol: "☹︎", type: .left),
        .init(symbol: "☹︎", type: .right)
    ]
    private var counter = 0
    private let targetCount = 10
    
    func render(in window: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            view.widthAnchor.constraint(equalTo: window.widthAnchor),
            view.heightAnchor.constraint(equalTo: window.heightAnchor)
        ])
    }
    
    func react(toInput key: KeyType) {
        counter += 1
        if counter >= targetCount {
            delegate?.fixed()
        }
    }
}
