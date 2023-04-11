import UIKit

class TwoButtonKeyboardView: UIView {
    private let backgroundImageView = UIImageView()
    let leftButton = KeyButton()
    let rightButton = KeyButton()
    
    init(designImage: UIImage, buttonImage: UIImage) {
        super.init(frame: .zero)
        setupUI(designImage: designImage, buttonImage: buttonImage)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI(designImage: UIImage(), buttonImage: UIImage())
    }
    
    func setup(symbols: [String], textAttributes: [NSAttributedString.Key : Any]) {
        guard symbols.count == 2 else { return }

        leftButton.setAttributedTitle(NSAttributedString(string: symbols[0], attributes: textAttributes), for: .normal)
        rightButton.setAttributedTitle(NSAttributedString(string: symbols[1], attributes: textAttributes), for: .normal)
    }
}

private extension TwoButtonKeyboardView {
    func setupUI(designImage: UIImage, buttonImage: UIImage) {
        addSubview(backgroundImageView)
        backgroundColor = .clear
        
        backgroundImageView.image = designImage
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layer.cornerRadius = 4
        backgroundImageView.backgroundColor = .clear
        
        addSubview(leftButton)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setBackgroundImage(buttonImage, for: .normal)
        addSubview(rightButton)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setBackgroundImage(buttonImage, for: .normal)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            leftButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9),
            rightButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9),
            leftButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.45),
            rightButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.45),
            
            leftButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            leftButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -5),
            rightButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 5)
        ])
    }
}
