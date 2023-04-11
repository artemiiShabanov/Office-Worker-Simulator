import SpriteKit

protocol ClickingSceneDelegate: AnyObject {
    func finished(success: Bool)
}

private enum ButtonType: Int, CaseIterable {
    case single = 1
    case double = 2
    case triple = 3
    case quadriple = 4
    
    var next: ButtonType {
        switch self {
        case .single:
            return .double
        case .double:
            return .triple
        case .triple:
            return .quadriple
        case .quadriple:
            return .quadriple
        }
    }
    var prev: ButtonType {
        switch self {
        case .single:
            return .single
        case .double:
            return .single
        case .triple:
            return .double
        case .quadriple:
            return .triple
        }
    }
}

class ClickingScene: SKScene {
    enum Direction {
        case left
        case right
    }
    
    private enum Layer {
        static let button: CGFloat = 1
        static let `static`: CGFloat = 2
        static let cursor: CGFloat = 3
    }
    
    private enum PhysicsCategory {
        static let none: UInt32 = 0
        static let button: UInt32 = 1
        static let bombButton: UInt32 = 2
        static let anyButton: UInt32 = button + bombButton
        static let cursor: UInt32 = 4
        static let finishLine: UInt32 = 8
        static let nextLine: UInt32 = 16
    }
    
    // MARK: - Properties
    
    private let difficulty: Difficulty
    private let speedupFactor: Double
    private let initialVelocity: CGFloat
    private var bombChance: Double
    private var progression: Double
    private var wasBomb = false
    
    private var cursor: SKSpriteNode!
    private var finishLine: SKSpriteNode!
    private var nextLine: SKSpriteNode!
    private var cells: [SKSpriteNode] = []
    private var cursorPosition: Int = 2 {
        didSet {
            var pos = cells[cursorPosition].position
            pos.x += CGFloat.random(in: -5...5)
            pos.y += CGFloat.random(in: -5...5)
            let dif: CGFloat = oldValue < cursorPosition ? 1 : -1
            var pos1 = pos
            pos1.x += dif * 5
            var pos2 = pos
            pos2.x -= dif * 3
            cursor.run(.sequence([
                .move(to: pos1, duration: 0.05),
                .move(to: pos2, duration: 0.05),
                .move(to: pos, duration: 0.1)
            ]))
        }
    }
    var count = 0
    private let numberOfPositions = 6
    private var succeded: Bool?
    
    weak var clickingSceneDelegate: ClickingSceneDelegate?
    
    // MARK: - SKScene
    
    init(size: CGSize, difficulty: Difficulty) {
        self.difficulty = difficulty
        switch difficulty {
        case .intern:
            self.initialVelocity = 50
            self.speedupFactor = 0.015
        case .employee:
            self.initialVelocity = 70
            self.speedupFactor = 0.02
        case .manager:
            self.initialVelocity = 75
            self.speedupFactor = 0.022
        case .CEO:
            self.initialVelocity = 80
            self.speedupFactor = 0.025
        }
        self.bombChance = 0
        self.progression = 0
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        addMovingBackground(with: Textures.Tasks.Clicking.bg, direction: .bottom, duration: 10)
        setupPhysics()
        setupStatic()
        setupCursor()
        spamButton()
        runTimer(sec: 60, tick: { [weak self] _ in
            guard let self else { return }
            self.physicsWorld.speed += self.speedupFactor
            self.bombChance = min(1, self.bombChance + 1.0/60.0)
            self.progression += 1.0/60.0
        }, finish: { [weak self] in
            guard let self else { return }
            self.gamecompleted()
        })
    }
    
    // MARK: - API
                 
    func move(to d: Direction) {
        if let succeded {
            clickingSceneDelegate?.finished(success: succeded)
            return
        }
        
        switch d {
        case .left:
            if cursorPosition > 0 {
                cursorPosition -= 1
            }
        case .right:
            if cursorPosition < numberOfPositions - 1 {
                cursorPosition += 1
            }
        }
    }
    
}

// MARK: - Setup

private extension ClickingScene {
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }
    
    func setupStatic() {
        let cellWidth = size.width / CGFloat(numberOfPositions)
        
        for index in 0..<numberOfPositions {
            let cell = SKSpriteNode(color: .clear, size: .init(width: cellWidth * 0.7, height: cellWidth * 0.7))
            cell.position = CGPoint(x: cellWidth * CGFloat(index) + cellWidth / 2, y: cellWidth / 2 + 10)
            cell.zPosition = Layer.static
            
            cells.append(cell)
            addChild(cell)
        }
        
        let buttonSize = size.width / 10
        
        finishLine = SKSpriteNode(color: .red, size: .init(width: size.width, height: 10))
        finishLine.position = CGPoint(x: size.width / 2, y: -buttonSize - 5)
        finishLine.zPosition = Layer.static
        finishLine.physicsBody = SKPhysicsBody(rectangleOf: finishLine.size)
        finishLine.physicsBody?.categoryBitMask = PhysicsCategory.finishLine
        finishLine.physicsBody?.contactTestBitMask = PhysicsCategory.anyButton
        finishLine.physicsBody?.collisionBitMask = PhysicsCategory.none
        finishLine.physicsBody?.isDynamic = false
        addChild(finishLine)
        
        nextLine = SKSpriteNode(color: .clear, size: .init(width: size.width, height: 5))
        nextLine.position = CGPoint(x: size.width / 2, y: size.height - buttonSize * 2)
        nextLine.zPosition = Layer.static
        nextLine.physicsBody = SKPhysicsBody(rectangleOf: nextLine.size)
        nextLine.physicsBody?.categoryBitMask = PhysicsCategory.nextLine
        nextLine.physicsBody?.contactTestBitMask = PhysicsCategory.anyButton
        nextLine.physicsBody?.collisionBitMask = PhysicsCategory.none
        nextLine.physicsBody?.isDynamic = false
        addChild(nextLine)
    }
    
    func setupCursor() {
        cursor = SKSpriteNode(texture: Textures.Tasks.Clicking.coursor, size: cells[2].size)
        cursor.position = cells[2].position
        cursor.zPosition = Layer.cursor
        cursor.physicsBody = SKPhysicsBody(texture: Textures.Tasks.Clicking.coursor, size: cursor.size)
        cursor.physicsBody?.categoryBitMask = PhysicsCategory.cursor
        cursor.physicsBody?.contactTestBitMask = PhysicsCategory.anyButton
        cursor.physicsBody?.collisionBitMask = PhysicsCategory.none
        cursor.physicsBody?.isDynamic = false
        addChild(cursor)
    }
    
    func spamButton() {
        let buttonSize = size.width / 10
        let isBomb: Bool
        if wasBomb {
            isBomb = false
            wasBomb = false
        } else {
            isBomb = Double.random(in: 0...1) < bombChance
            if isBomb {
                wasBomb = true
            }
        }
        let type = randomButtonType(isBomb: isBomb)
        let button = SKSpriteNode(
            texture: isBomb ? Textures.Tasks.Clicking.bombButtons[type.rawValue - 1] : Textures.Tasks.Clicking.buttons[type.rawValue - 1],
            size: .init(width: buttonSize * CGFloat(type.rawValue), height: buttonSize)
        )
        let position = CGFloat.random(in: 0...(size.width-button.size.width)) + button.size.width / 2
        button.position = CGPoint(x: position, y: size.height + button.size.height)
        button.zPosition = Layer.button
        button.physicsBody = SKPhysicsBody(rectangleOf: button.size)
        button.physicsBody?.categoryBitMask = isBomb ? PhysicsCategory.bombButton : PhysicsCategory.button
        button.physicsBody?.contactTestBitMask = PhysicsCategory.cursor + PhysicsCategory.finishLine
        button.physicsBody?.collisionBitMask = PhysicsCategory.none
        button.physicsBody?.isDynamic = true
        
        button.physicsBody?.velocity = .init(dx: 0, dy: -initialVelocity)
        button.physicsBody?.linearDamping = 0
        
        addChild(button)
    }
    
    func randomButtonType(isBomb: Bool) -> ButtonType {
        let type = ButtonType.allCases.randomElement()!
        if isBomb {
            let chance = Double.random(in: 0...1) < progression
            return chance ? type.next : type
        } else {
            let chance = Double.random(in: 0...1) < progression
            return chance ? type.prev : type
        }
    }
}

// MARK: - Private

private extension ClickingScene {
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
        taskFailedOveralay() { [weak self] in
            self?.view?.isPaused = true
            Application.enableTouch()
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension ClickingScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard succeded == nil else {
            return
        }
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if secondBody.categoryBitMask & PhysicsCategory.cursor != 0 {
            if firstBody.categoryBitMask & PhysicsCategory.button != 0 {
                firstBody.node?.removeFromParent()
                firstBody.node?.physicsBody = nil
                animateClick()
            }
            if firstBody.categoryBitMask & PhysicsCategory.bombButton != 0 {
                animateClick()
                firstBody.node.map { explode(node: $0) }
                gameover()
            }
        }
        
        if secondBody.categoryBitMask & PhysicsCategory.finishLine != 0 {
            if firstBody.categoryBitMask & PhysicsCategory.button != 0 {
                gameover()
            }
            if firstBody.categoryBitMask & PhysicsCategory.bombButton != 0 {
                firstBody.node?.run(.fadeOut(withDuration: 0.5)) {
                    firstBody.node?.removeFromParent()
                }
            }
        }
        
        if secondBody.categoryBitMask & PhysicsCategory.nextLine != 0 {
            spamButton()
        }
    }
    
    func animateClick() {
        SoundPlayer.shared.play(sound: .mouseClick)
        Haptics.shared.play(type: .rigid)
        cursor.run(.sequence([
            .setTexture(Textures.Tasks.Clicking.coursorClick),
            .wait(forDuration: 0.1),
            .setTexture(Textures.Tasks.Clicking.coursor)
        ]))
    }
}
