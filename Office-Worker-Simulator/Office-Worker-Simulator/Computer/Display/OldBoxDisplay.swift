import UIKit

class OldBoxScreen: Display {
    private lazy var displayView = DisplayView(designImage: Images.Computer.oldDisplay, screenInsets: .init(top: 20, left: 20, bottom: 20, right: 20))
    
    func provideScreen() -> UIView {
        displayView.screen
    }
    
    func render(in view: UIView) {
        view.addSubview(displayView)
        displayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            displayView.topAnchor.constraint(equalTo: view.topAnchor),
            displayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            displayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            displayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func clear() {
        displayView.screen.subviews.forEach { $0.removeFromSuperview() }
    }
}
