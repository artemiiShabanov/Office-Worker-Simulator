import UIKit

protocol FillCountProgramDelegate: AnyObject {
    func finishedCounting()
}

class FillCountProgram: Program {
    private let text: String
    private let accentColor: UIColor
    private let bgColor: UIColor
    private let count: Int
    private let offImage: UIImage
    private let onImage: UIImage
    
    init(
        text: String,
        accentColor: UIColor,
        bgColor: UIColor,
        count: Int,
        offImage: UIImage = UIImage(systemName: "circle")!,
        onImage: UIImage = UIImage(systemName: "circle.fill")!
    ) {
        self.text = text
        self.accentColor = accentColor
        self.bgColor = bgColor
        self.count = count
        self.offImage = offImage
        self.onImage = onImage
    }
    
    private var coursor = -1
    
    private func circle() -> UIImageView {
        let circle = UIImageView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = .clear
        circle.tintColor = accentColor
        circle.image = offImage
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 20),
            circle.heightAnchor.constraint(equalToConstant: 20),
        ])
        return circle
    }
    private lazy var circles: [UIImageView] = {
        (0..<count).map { _ in circle() }
    }()
    
    private lazy var view = {
        let view = UIView()
        view.backgroundColor = bgColor
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        view.addSubview(label)
        label.text = text
        label.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        label.contentMode = .top
        label.numberOfLines = 0
        label.textColor = accentColor
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])
        
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(UIView())
        circles.forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.addArrangedSubview(UIView())
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return view
    }()
    
    weak var delegate: FillCountProgramDelegate?
    var keys: [Key] { [
        .init(symbol: "←", type: .left),
        .init(symbol: "→", type: .right)
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
        switch key {
        case .left:
            guard coursor >= 0 else { return }
            circles[coursor].image = offImage
            coursor -= 1
        case .right:
            guard coursor < count - 1 else { return }
            coursor += 1
            circles[coursor].image = onImage
            if coursor == count - 1 {
                delegate?.finishedCounting()
            }
        }
    }
    
}
