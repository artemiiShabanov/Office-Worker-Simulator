import UIKit

protocol TypingProgramDelegate: AnyObject {
    func finished()
}

class TypingProgram: Program {
    private let lines: [String]
    private let textColor: UIColor
    private let bgColor: UIColor
    private let keyText: String
    
    init(lines: [String], textColor: UIColor = .white, bgColor: UIColor = .black, keyText: String = "👾") {
        self.lines = lines
        self.textColor = textColor
        self.bgColor = bgColor
        self.keyText = keyText
    }
    
    private var next = 0
    
    private func label() -> UILabel {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        label.textColor = textColor
        label.textAlignment = .center
        label.contentMode = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    private lazy var labels: [UILabel] = {
        lines.map { _ in label() }
    }()
    private lazy var view = {
        let view = UIView()
        view.backgroundColor = bgColor
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        labels.forEach {
            stackView.addArrangedSubview($0)
            $0.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }()
    
    weak var delegate: TypingProgramDelegate?
    var keys: [Key] { [
        .init(symbol: keyText, type: .left),
        .init(symbol: keyText, type: .right)
    ] }
    
    func render(in window: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            view.widthAnchor.constraint(equalTo: window.widthAnchor),
            view.heightAnchor.constraint(equalTo: window.heightAnchor),
        ])
    }
    
    func react(toInput key: KeyType) {
        if next < lines.count {
            labels[next].setTyping(text: lines[next])
            next += 1
        } else {
            delegate?.finished()
        }
    }
    
}

fileprivate extension UILabel {
    func setTyping(text: String, characterDelay: TimeInterval = 5.0) {
        self.text = ""
        let writingTask = DispatchWorkItem { [weak self] in
            text.forEach { char in
                DispatchQueue.main.async {
                    self?.text?.append(char)
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
            }
        }
        
        let queue: DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
        queue.asyncAfter(deadline: .now() + 0.05, execute: writingTask)
    }
}
