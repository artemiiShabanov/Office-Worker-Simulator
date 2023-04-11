import UIKit
import SpriteKit
import GameplayKit
import SPConfetti

class GameViewController: UIViewController {
    @IBOutlet private var bg: UIImageView!
    @IBOutlet private var desk: UIImageView!
    @IBOutlet private var screenContainer: UIView!
    @IBOutlet private var keyboardContainer: UIView!
    
    @IBOutlet private var internBadge: UIImageView!
    @IBOutlet private var employeeBadge: UIImageView!
    @IBOutlet private var managerBadge: UIImageView!
    @IBOutlet private var ceoBadge: UIImageView!
    
    @IBOutlet private var internArrow: UIImageView!
    @IBOutlet private var employeeArrow: UIImageView!
    @IBOutlet private var managerArrow: UIImageView!
    @IBOutlet private var ceoArrow: UIImageView!

    private lazy var computer = Computer(screenContainer: screenContainer, keyboardContainer: keyboardContainer)
    private lazy var game = Game(computer: computer)
    
    private var style: OfficeStyle = .lofi {
        didSet {
            bg.image = style.bgImage
            desk.image = style.deskImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style = Preferences.shared.officeStyle
        
        computer.plugIn(display: OldBoxScreen())
        computer.plugIn(keyboard: OldTwoButtonKeyboard())
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(cheatInput))
        gr.numberOfTapsRequired = 5
        screenContainer.addGestureRecognizer(gr)
        
        game.delegate = self
        game.start()
        
        updateDifficulties()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Preferences.shared.welcomed {
            SPConfetti.startAnimating(.fullWidthToDown, particles: [.arc, .star], duration: 1)
        }
        game.start()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Private

private extension GameViewController {
    @objc func cheatInput() {
        game.enterCheatCode()
    }
    
    func updateDifficulties() {
        let completed = Preferences.shared.completedDifficulties
        let selected = Preferences.shared.difficulty
        
        for dif in Difficulty.allCases {
            let isCompleted = completed.contains(dif)
            let isSelected = selected == dif
            let imageView: UIImageView
            let arrowView: UIImageView
            switch dif {
            case .intern:
                imageView = internBadge
                arrowView = internArrow
            case .employee:
                imageView = employeeBadge
                arrowView = employeeArrow
            case .manager:
                imageView = managerBadge
                arrowView = managerArrow
            case .CEO:
                imageView = ceoBadge
                arrowView = ceoArrow
            }
            imageView.alpha = isCompleted ? 1 : isSelected ? 0.4 : 0.1
            arrowView.alpha = 0.5
            arrowView.isHidden = isSelected ? false : true
        }
    }
}

// MARK: - GameDelegate

extension GameViewController: GameDelegate {
    func changedDifficulty() {
        updateDifficulties()
    }
    
    func changed(style: OfficeStyle) {
        self.style = style
    }
}
