import SpriteKit

protocol TypingSceneDelegate: AnyObject {
    func finished(success: Bool)
}

private class StupidLanguageModel {
    private var prev: Symbol?
    private var count = 0
    
    func generateNext(inputChance: Double) -> Symbol {
        let sym: Symbol
        if let prev {
            switch prev {
            case .space:
                sym = generateSymbolOrInput(inputChance: inputChance)
            case .input, .symbol:
                let char = Texts.inputLorem[count % Texts.inputLorem.count]
                sym = char == "*" ? generateInput() : (char.isLetter ? generateSymbolOrInput(inputChance: inputChance) : .space)
            }
        } else {
            sym = generateSymbol()
        }
        prev = sym
        count += 1
        return sym
    }
    
    private func generateSymbolOrInput(inputChance: Double) -> Symbol {
        Double.random(in: 0...1) < inputChance ? generateInput() : generateSymbol()
    }
    
    private func generateSymbol() -> Symbol {
        .symbol(image: randomCharImage())
    }
    
    private func generateInput() -> Symbol {
        .input(Bool.random() ? .left : .right)
    }
    
}

private enum Symbol {
    enum InputSymbol {
        case left
        case right
        
        var texture: SKTexture {
            switch self {
            case .left:
                return Textures.Tasks.Typing.circle
            case .right:
                return Textures.Tasks.Typing.square
            }
        }
    }
    case space
    case symbol(image: UIImage)
    case input(InputSymbol)
}

class TypingScene: SKScene {
    private enum Layer {
        static let background: CGFloat = 1
        static let `static`: CGFloat = 2
        static let symbols: CGFloat = 3
    }
    
    private enum PhysicsCategory {
        static let none: UInt32 = 0
        static let symbol: UInt32 = 1
        static let inputSymbol: UInt32 = 2
        static let anySymbol: UInt32 = symbol + inputSymbol
        static let finishLine: UInt32 = 4
        static let nextLine: UInt32 = 8
    }
    
    private let lineCount: CGFloat = 15
    private let speedupFactor: Double
    private let initialVelocity: CGFloat
    private var inputChance: Double
    private var progression: Double
    
    // MARK: - Properties
    
    private let difficulty: Difficulty
    
    private var bg: SKSpriteNode!
    private var underline: SKSpriteNode!
    private var finishLine: SKSpriteNode!
    private var nextLine: SKSpriteNode!
    private let languageModel = StupidLanguageModel()
    private var succeded: Bool?
    
    weak var typingSceneDelegate: TypingSceneDelegate?
    
    // MARK: - SKScene
    
    init(size: CGSize, difficulty: Difficulty) {
        self.difficulty = difficulty
        self.inputChance = 0.2
        switch difficulty {
        case .intern:
            self.initialVelocity = 65
            self.speedupFactor = 0.02
        case .employee:
            self.initialVelocity = 75
            self.speedupFactor = 0.03
        case .manager:
            self.initialVelocity = 80
            self.speedupFactor = 0.033
        case .CEO:
            self.initialVelocity = 85
            self.speedupFactor = 0.038
        }
        self.progression = 0
        super.init(size: size)
        self.backgroundColor = .white
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        addMovingBackground(with: Textures.Tasks.Typing.bg, direction: .left, duration: 10)
        setupPhysics()
        setupStatic()
        spamSymbol()
        
        runTimer(sec: 60, tick: { [weak self] _ in
            self?.physicsWorld.speed += self?.speedupFactor ?? 0
            self?.progression += 1.0/60.0
            self?.inputChance += 1.0/120.0
        }, finish: { [weak self] in
            guard let self else { return }
            self.gamecompleted()
        })
    }
    
    // MARK: - API
                 
    func input(key: KeyType) {
        if let succeded {
            typingSceneDelegate?.finished(success: succeded)
            return
        }
        
        guard let node = centerNode() else {
            Haptics.shared.play(type: .old)
            return
        }
        
        guard let side = node.userData?["side"] as? Symbol.InputSymbol else {
            assertionFailure()
            return
        }
        
        func catched(node: SKNode) {
            node.alpha = 1
            node.run(.sequence([
                .scale(to: 1.1, duration: 0.1),
                .scale(to: 1.0, duration: 0.1),
            ]))
            node.physicsBody?.categoryBitMask = PhysicsCategory.symbol
            (node as? SKSpriteNode)?.colorBlendFactor = 1
        }
        
        switch key {
        case .left:
            if side == .left {
                catched(node: node)
            } else {
                gameover()
                return
            }
        case .right:
            if side == .right {
                catched(node: node)
            } else {
                gameover()
                return
            }
        }
    }
    
}

// MARK: - Setup

private extension TypingScene {
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }
    
    func setupStatic() {
        let symbolSize = size.width / lineCount
        
        bg = SKSpriteNode(color: .white, size: .init(width: size.width, height: size.height / 3))
        bg.position = CGPoint(x: 0.5 * size.width, y: 0.5 * size.height)
        bg.zPosition = Layer.background
        addChild(bg)
        
        underline = SKSpriteNode(color: .black, size: .init(width: symbolSize, height: 3))
        underline.position = CGPoint(x: 0.5 * size.width, y: 0.5 * size.height - symbolSize / 2 - 5)
        underline.zPosition = Layer.static
        underline.run(.repeatForever(.sequence([
            .fadeOut(withDuration: 0.4),
            .fadeIn(withDuration: 0.4)
        ])))
        addChild(underline)
        
        finishLine = SKSpriteNode(color: .clear, size: .init(width: 10, height: size.height))
        finishLine.position = CGPoint(x: 0.25 * size.width, y: 0.5 * size.height)
        finishLine.zPosition = Layer.static
        finishLine.physicsBody = SKPhysicsBody(rectangleOf: finishLine.size)
        finishLine.physicsBody?.categoryBitMask = PhysicsCategory.finishLine
        finishLine.physicsBody?.contactTestBitMask = PhysicsCategory.inputSymbol
        finishLine.physicsBody?.collisionBitMask = PhysicsCategory.none
        finishLine.physicsBody?.isDynamic = false
        addChild(finishLine)
        
        nextLine = SKSpriteNode(color: .clear, size: .init(width: 5, height: size.height))
        nextLine.position = CGPoint(x: size.width - symbolSize - 10, y: 0.5 * size.height)
        nextLine.zPosition = Layer.static
        nextLine.physicsBody = SKPhysicsBody(rectangleOf: nextLine.size)
        nextLine.physicsBody?.categoryBitMask = PhysicsCategory.nextLine
        nextLine.physicsBody?.contactTestBitMask = PhysicsCategory.anySymbol
        nextLine.physicsBody?.collisionBitMask = PhysicsCategory.none
        nextLine.physicsBody?.isDynamic = false
        addChild(nextLine)
    }
}

// MARK: - Private

private extension TypingScene {
    func spamSymbol() {
        let symbolWidth = size.width / lineCount
        let symbolSize = CGSize(width: symbolWidth, height: symbolWidth)
        let sym = languageModel.generateNext(inputChance: inputChance)
    
        let node: SKSpriteNode
        switch sym {
        case .space:
            node = .init(color: .clear, size: symbolSize)
        case .symbol(let img):
            node = .init(texture: .init(image: img))
            node.aspectFillToSize(fillSize: symbolSize)
        case .input(let input):
            node = .init(texture: input.texture, size: symbolSize)
            
            node.alpha = 0.3
            node.colorBlendFactor = max(0, 1 - progression * 1.5)
            switch input {
            case .left:
                node.color = .red
                node.userData = [
                    "side": Symbol.InputSymbol.left,
                ];
            case .right:
                node.color = .blue
                node.userData = [
                    "side": Symbol.InputSymbol.right,
                ];
            }
        }
        node.position = CGPoint(x: size.width + symbolWidth / 2, y: size.height / 2)
        node.zPosition = Layer.symbols
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.velocity = .init(dx: -initialVelocity, dy: 0)
        node.physicsBody?.linearDamping = 0
        if case .input = sym {
            node.physicsBody?.categoryBitMask = PhysicsCategory.inputSymbol
        } else {
            node.physicsBody?.categoryBitMask = PhysicsCategory.symbol
        }
        node.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(node)
    }
    
    func centerNode() -> SKNode? {
        let symbolSize = size.width / lineCount
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
            return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
        }
        
        let possibleNodes = children.filter {
            (($0.physicsBody?.categoryBitMask ?? 0) & PhysicsCategory.inputSymbol != 0)
            && CGPointDistance(from: $0.position, to: center) < symbolSize * 2
        }.sorted {
            $0.position.x < $1.position.x
        }
        
        if let nearest = possibleNodes.first {
            return nearest
        } else {
            return nil
        }
    }
    
    func gamecompleted() {
        succeded = true
        Haptics.shared.play(type: .success)
        physicsWorld.speed = 0
        Application.disableTouch()
        taskSuccededOveralay { [weak self] in
            self?.view?.isPaused = true
            Application.enableTouch()
        }
    }
    
    func gameover() {
        guard !Preferences.shared.immortal else {
            return
        }
        succeded = false
        Haptics.shared.play(type: .old)
        physicsWorld.speed = 0
        Application.disableTouch()
        taskFailedOveralay { [weak self] in
            self?.view?.isPaused = true
            Application.enableTouch()
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension TypingScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard succeded == nil else {
            return
        }
        let firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if secondBody.categoryBitMask & PhysicsCategory.nextLine != 0 {
            spamSymbol()
        }
        
        if secondBody.categoryBitMask & PhysicsCategory.finishLine != 0 {
            gameover()
        }
    }
    
}

private let charset = "qwertyuiopasdfghjklzxcvbnmqwèéeêëēėęÿûüùúūîïíīįìôöòóœøōõàáâäæãåāßśšłžźżçćčñńйцукенгшщзхъфывапролджэёячсмитьбю".uppercased()

private func randomCharImage() -> UIImage {
    String(charset.randomElement()!).image(
        withAttributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.monospacedSystemFont(ofSize: 40.0, weight: .medium),
        ])!
}

private extension String {
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                    withAttributes: attributes)
        }
    }
}

private extension SKSpriteNode {

    func aspectFillToSize(fillSize: CGSize) {

        if texture != nil {
            self.size = texture!.size()

            let verticalRatio = fillSize.height / self.texture!.size().height
            let horizontalRatio = fillSize.width /  self.texture!.size().width

            let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio

            self.setScale(scaleRatio)
        }
    }

}
