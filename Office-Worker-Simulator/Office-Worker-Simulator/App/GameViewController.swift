import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    @IBOutlet private var screenContainer: UIView!
    @IBOutlet private var keyboardContainer: UIView!

    private lazy var computer = Computer(screenContainer: screenContainer, keyboardContainer: keyboardContainer)
    private lazy var game = Game(computer: computer)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        computer.plugIn(display: OldBoxScreen())
        computer.plugIn(keyboard: OldTwoButtonKeyboard())
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
