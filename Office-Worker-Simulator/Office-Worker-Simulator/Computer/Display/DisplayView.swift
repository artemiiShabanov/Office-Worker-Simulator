import UIKit

class DisplayView: UIView {
    private let container = UIView()
    private let screenView = UIView()
    private let imageView = UIImageView()
    
    var screen: UIView { screenView }
    
    init(designImage: UIImage, screenInsets: UIEdgeInsets) {
        super.init(frame: .zero)
        setupUI(designImage: designImage, screenInsets: screenInsets)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI(designImage: UIImage(), screenInsets: .zero)
    }
}

private extension DisplayView {
    func setupUI(designImage: UIImage, screenInsets: UIEdgeInsets) {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = designImage
        imageView.contentMode = .scaleAspectFill
        
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(screenView)
        screenView.translatesAutoresizingMaskIntoConstraints = false
        screenView.backgroundColor = .blue
        screenView.layer.cornerRadius = 8
        screenView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: designImage.size.width / designImage.size.height),
            
            container.topAnchor.constraint(equalTo: imageView.topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 3 / 4),
            
            screenView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            screenView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            screenView.widthAnchor.constraint(equalTo: container.widthAnchor, constant: -screenInsets.left - screenInsets.right),
            screenView.heightAnchor.constraint(equalTo: container.heightAnchor, constant: -screenInsets.top - screenInsets.bottom)
        ])
    }
}
