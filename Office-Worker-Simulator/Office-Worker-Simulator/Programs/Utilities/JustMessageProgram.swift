import UIKit

protocol JustMessageProgramDelegate: AnyObject {
    func tap(key: KeyType)
}

class JustMessageProgram: Program {
    private let bgColor: UIColor
    private let text: String
    private let textColor: UIColor
    
    init(bgColor: UIColor = .blue, text: String, textColor: UIColor = .white) {
        self.bgColor = bgColor
        self.text = text
        self.textColor = textColor
    }
    
    private lazy var view = {
        let view = UIView()
        view.backgroundColor = self.bgColor
        let label = UILabel()
        view.addSubview(label)
        label.text = text
        label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = self.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    weak var delegate: JustMessageProgramDelegate?
    var keys: [Key] = [
        .init(symbol: "Ok", type: .left),
        .init(symbol: "Ok", type: .right)
    ]
    
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
        delegate?.tap(key: key)
    }
    
}
