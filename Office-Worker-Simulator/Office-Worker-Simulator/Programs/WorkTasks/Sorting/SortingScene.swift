import SpriteKit

protocol SortingSceneDelegate: AnyObject {
    func finished(success: Bool)
}

private enum Side {
    case left
    case right
}

private enum FileColor: String, CaseIterable {
    case blue = "b"
    case yellow = "y"
    case orange = "o"
    case red = "r"
    case green = "g"
    case purple = "p"
}

private enum FileType: Int, CaseIterable {
    case pdf = 1
    case rar = 2
    case txt = 3
    case exe = 4
    case html = 5
    
    var name: String {
        switch self {
        case .pdf:
            return "pdf"
        case .rar:
            return "rar"
        case .txt:
            return "txt"
        case .exe:
            return "exe"
        case .html:
            return "html"
        }
    }
}

private struct File {
    let color: FileColor
    let name: String
    let type: FileType
    var side: Side {
        switch color {
        case .blue, .yellow, .orange:
            return .left
        case .red, .green, .purple:
            return .right
        }
    }
    var texture: SKTexture {
        return Textures.Tasks.Sorting.buttons["\(type.rawValue)_\(color.rawValue)"]!
    }
    var fullName: String {
        "\(name).\(type.name)"
    }
}

private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }

private func randomFile() -> File {
    File(color: FileColor.allCases.randomElement()!, name: randomString(length: Int.random(in: 2...10)), type: FileType.allCases.randomElement()!)
}

class SortingScene: SKScene {
    enum SortDirection {
        case left
        case right
    }
    
    private enum Layer {
        static let files: CGFloat = 1
        static let `static`: CGFloat = 2
    }
    
    private enum PhysicsCategory {
        static let none: UInt32 = 0
        static let leftFile: UInt32 = 1
        static let rightFile: UInt32 = 2
        static let file: UInt32 = 3
        static let bin: UInt32 = 4
        static let leftFolder: UInt32 = 8
        static let rightFolder: UInt32 = 16
        static let folder: UInt32 = leftFolder + rightFolder
    }
    
    // MARK: - Properties
    
    private let difficulty: Difficulty
    private var delayToNext: Double
    private var moveDuration: Double
    
    private var leftFolder: SKSpriteNode!
    private var rightFolder: SKSpriteNode!
    private var bin: SKSpriteNode!
    private var filesQueue = Queue<SKSpriteNode>()
    
    private var succeded: Bool?
    
    weak var sortingSceneDelegate: SortingSceneDelegate?
    
    // MARK: - SKScene
    
    init(size: CGSize, difficulty: Difficulty) {
        self.difficulty = difficulty
        switch difficulty {
        case .intern:
            self.delayToNext = 1.2
            self.moveDuration = 4.8
        case .employee:
            self.delayToNext = 1
            self.moveDuration = 4.2
        case .manager:
            self.delayToNext = 0.9
            self.moveDuration = 4.0
        case .CEO:
            self.delayToNext = 0.85
            self.moveDuration = 3.6
        }
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        addMovingBackground(with: Textures.Tasks.Sorting.bg, direction: .top, duration: 10)
        setupPhysics()
        setupStatic()
        startSpammingFiles()
        runTimer(sec: 60, tick: { [weak self] _ in
            self?.delayToNext -= 0.01
            self?.moveDuration -= 0.05
        }, finish: { [weak self] in
            guard let self else { return }
            self.gamecompleted()
        })
    }
    
    // MARK: - API
                   
    func sort(to d: SortDirection) {
        if let succeded {
            sortingSceneDelegate?.finished(success: succeded)
            return
        }
        guard let file = filesQueue.dequeue() else {
            return
        }
        file.removeAllActions()
        file.run(.move(to: d == .left ? leftFolder.position : rightFolder.position, duration: 0.2))
    }
    
}

// MARK: - Setup

private extension SortingScene {
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }
    
    func setupStatic() {
        let dsize = size.width / 8
        
        leftFolder = SKSpriteNode(texture: Textures.Tasks.Sorting.folderLeft, size: .init(width: dsize, height: dsize))
        leftFolder.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        leftFolder.zPosition = Layer.static
        leftFolder.physicsBody = SKPhysicsBody(rectangleOf: leftFolder.size)
        leftFolder.physicsBody?.categoryBitMask = PhysicsCategory.leftFolder
        leftFolder.physicsBody?.contactTestBitMask = PhysicsCategory.file
        leftFolder.physicsBody?.collisionBitMask = PhysicsCategory.none
        leftFolder.physicsBody?.isDynamic = false
        addChild(leftFolder)
        
        rightFolder = SKSpriteNode(texture: Textures.Tasks.Sorting.folderRight, size: .init(width: dsize, height: dsize))
        rightFolder.position = CGPoint(x: size.width * 0.9, y: size.height * 0.5)
        rightFolder.zPosition = Layer.static
        rightFolder.physicsBody = SKPhysicsBody(rectangleOf: rightFolder.size)
        rightFolder.physicsBody?.categoryBitMask = PhysicsCategory.rightFolder
        rightFolder.physicsBody?.contactTestBitMask = PhysicsCategory.file
        rightFolder.physicsBody?.collisionBitMask = PhysicsCategory.none
        rightFolder.physicsBody?.isDynamic = false
        addChild(rightFolder)
        
        bin = SKSpriteNode(texture: Textures.Tasks.Sorting.bin, size: .init(width: dsize, height: dsize))
        bin.position = CGPoint(x: size.width * 0.5, y: size.height * 0.9)
        bin.zPosition = Layer.static
        bin.physicsBody = SKPhysicsBody(rectangleOf: bin.size)
        bin.physicsBody?.categoryBitMask = PhysicsCategory.bin
        bin.physicsBody?.contactTestBitMask = PhysicsCategory.file
        bin.physicsBody?.collisionBitMask = PhysicsCategory.none
        bin.physicsBody?.isDynamic = false
        addChild(bin)
    }
    
    func startSpammingFiles() {
        func step() {
            run(SKAction.sequence([
                SKAction.run(spamFile),
                SKAction.wait(forDuration: delayToNext)
            ])) {
                step()
            }
        }
        step()
    }
    
    func spamFile() {
        let dsize = size.width / 10
        let file = randomFile()
        let node = SKSpriteNode(texture: file.texture, size: .init(width: dsize, height: dsize))
        node.zPosition = Layer.files
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = file.side == .left ? PhysicsCategory.leftFile : PhysicsCategory.rightFile
        node.physicsBody?.contactTestBitMask = PhysicsCategory.bin + PhysicsCategory.folder
        node.physicsBody?.collisionBitMask = PhysicsCategory.none
        node.physicsBody?.isDynamic = true
        
        node.position = CGPoint(x: size.width / 2 + CGFloat.random(in: -dsize...dsize), y: -node.size.height)
        
        let label = SKLabelNode(fontNamed: UIFont.monospacedSystemFont(ofSize: 7, weight: .medium).fontName)
        label.fontSize = 7
        label.text = file.fullName
        label.position = .init(x: 0, y: -node.size.height / 2 - 10)
        node.addChild(label)
        
        addChild(node)
        filesQueue.enqueue(node)
        
        let actionMove = SKAction.move(
            to: bin.position,
            duration: moveDuration
        )
        let actionMoveDone = SKAction.removeFromParent()
        node.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
}

// MARK: - Private

private extension SortingScene {
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
        Application.disableTouch()
        taskFailedOveralay() { [weak self] in
            self?.view?.isPaused = true
            Application.enableTouch()
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension SortingScene: SKPhysicsContactDelegate {
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
        
        if ((firstBody.categoryBitMask & PhysicsCategory.file != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.bin != 0)) {
            firstBody.node.map { explode(node: $0) }
            gameover()
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.leftFile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.leftFolder != 0))
            ||
            ((firstBody.categoryBitMask & PhysicsCategory.rightFile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.rightFolder != 0)) {
            firstBody.node?.removeFromParent()
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.leftFile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.rightFolder != 0)) {
            firstBody.node.map { explode(node: $0) }
            gameover()
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.rightFile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.leftFolder != 0)) {
            firstBody.node.map { explode(node: $0) }
            gameover()
        }
    }
}
