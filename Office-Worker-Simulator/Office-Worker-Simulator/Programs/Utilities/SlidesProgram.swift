import UIKit

protocol SlidesProgramDelegate: AnyObject {
    func lastSlideWatched()
}

class SlidesProgram: Program {
    private let slides: [UIImage]
    
    init(slides: [UIImage]) {
        self.slides = slides
    }
    
    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var view = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        return view
    }()
    private var currentSlide = 0 {
        didSet {
            imageView.image = slides[currentSlide]
        }
    }
    
    weak var delegate: SlidesProgramDelegate?
    var keys: [Key] = [
        .init(symbol: "←", type: .left),
        .init(symbol: "→", type: .right)
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
        currentSlide = 0
    }
    
    func react(toInput key: KeyType) {
        switch key {
        case .left:
            currentSlide = max(0, currentSlide - 1)
        case .right:
            if currentSlide == slides.count - 1 {
                delegate?.lastSlideWatched()
            } else {
                currentSlide += 1
            }
        }
    }
    
}
