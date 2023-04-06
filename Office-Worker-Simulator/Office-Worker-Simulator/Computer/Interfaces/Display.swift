import UIKit

protocol Display {
    func provideScreen() -> UIView
    func render(in view: UIView)
    func clear()
}
