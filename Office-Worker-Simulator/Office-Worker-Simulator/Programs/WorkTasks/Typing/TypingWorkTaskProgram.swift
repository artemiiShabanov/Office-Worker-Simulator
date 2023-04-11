import SpriteKit
import AVFoundation

class TypingWorkTaskProgram: WorkTaskProgram {
    private let difficulty: Difficulty
    init(difficulty: Difficulty) {
        self.difficulty = difficulty
    }
    
    private lazy var view = {
        let view = SKView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        return view
    }()
    private var scene: TypingScene!
    
    private lazy var backgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "typing_theme", withExtension: "wav") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    
    weak var delegate: WorkTaskProgramDelegate?
    var keys: [Key] = [
        .init(symbol: "○", type: .left),
        .init(symbol: "□", type: .right)
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
        
        scene = .init(size: window.bounds.size, difficulty: difficulty)
        scene.typingSceneDelegate = self
        scene.scaleMode = .aspectFill
        view.presentScene(scene)
        
        backgroundMusic?.play()
    }
    
    func react(toInput key: KeyType) {
        scene.input(key: key)
    }
    
}

extension TypingWorkTaskProgram: TypingSceneDelegate {
    func finished(success: Bool) {
        delegate?.finished(success: success)
    }
}
