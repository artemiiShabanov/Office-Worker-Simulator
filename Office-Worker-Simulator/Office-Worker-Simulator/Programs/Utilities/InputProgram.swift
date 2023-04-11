import UIKit

protocol InputProgramDelegate: AnyObject {
    func output(string: String)
}

class InputProgram: Program {
    private let bgColor: UIColor
    private let textColor: UIColor
    private let leftKey: String
    private let rightKey: String
    private var string = "" {
        didSet {
            label.text = string + "_"
        }
    }
    
    init(bgColor: UIColor = .black, textColor: UIColor = .white, leftKey: String, rightKey: String) {
        self.bgColor = bgColor
        self.textColor = textColor
        self.leftKey = leftKey
        self.rightKey = rightKey
    }
    
    private lazy var label = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = textColor
        label.textAlignment = .center
        label.contentMode = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var view = {
        let view = UIView()
        view.backgroundColor = bgColor
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])
        return view
    }()
    
    weak var delegate: InputProgramDelegate?
    var keys: [Key] { [
        .init(symbol: leftKey, type: .left),
        .init(symbol: rightKey, type: .right)
    ]}
    
    func render(in window: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            view.widthAnchor.constraint(equalTo: window.widthAnchor),
            view.heightAnchor.constraint(equalTo: window.heightAnchor)
        ])
        string = ""
    }
    
    func react(toInput key: KeyType) {
        switch key {
        case .left:
            string += leftKey
        case .right:
            string += rightKey
        }
        delegate?.output(string: string)
    }
    
}
