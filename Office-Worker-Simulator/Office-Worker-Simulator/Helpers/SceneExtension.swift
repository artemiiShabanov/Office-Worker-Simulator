import SpriteKit

enum MoveDirection {
    case top
    case bottom
    case left
    case right
    
    var x: CGFloat {
        switch self {
        case .top:
            return 0
        case .bottom:
            return 0
        case .left:
            return -1
        case .right:
            return 1
        }
    }
    
    var y: CGFloat {
        switch self {
        case .top:
            return 1
        case .bottom:
            return -1
        case .left:
            return 0
        case .right:
            return 0
        }
    }
}

extension SKScene {
    func addMovingBackground(with texture: SKTexture, direction: MoveDirection, duration: CGFloat) {
        let widthHeightRatio  = texture.size().width / texture.size().height
        let widthRatio  = texture.size().width / size.width
        let heightRatio = texture.size().height / size.height
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.height * widthHeightRatio, height: size.height)
        } else {
            newSize = CGSize(width: size.width, height: size.width / widthHeightRatio)
        }
        
        for i in 0...1 {
            let slice = SKSpriteNode(texture: texture, size: newSize)
            slice.zPosition = -100
            slice.position = .init(
                x: (slice.size.width / 2.0 + slice.size.width * CGFloat(i) * -direction.x),
                y: (slice.size.height / 2.0 + slice.size.height * CGFloat(i) * -direction.y)
            )
            
            addChild(slice)
            
            let move = SKAction.moveBy(x: slice.size.width * direction.x, y: slice.size.height * direction.y, duration: duration)
            let moveReset = SKAction.moveBy(x: slice.size.width * -direction.x, y: slice.size.height * -direction.y, duration: 0)
            let moveLoop = SKAction.sequence([move, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            slice.run(moveForever)
        }
    }
    
    func runTimer(sec: Int, tick: @escaping Closure<Int>, finish: @escaping EmptyClosure) {
        let bg = SKSpriteNode(color: .black, size: .init(width: 35, height: 20))
        bg.position = .init(x: self.size.width - 26, y: self.size.height - 13)
        bg.zPosition = CGFloat.greatestFiniteMagnitude
        addChild(bg)
        let label = SKLabelNode(fontNamed: UIFont.monospacedSystemFont(ofSize: 15, weight: .black).fontName)
        label.fontSize = 15
        label.fontColor = .white
        label.position = CGPointMake(0, -6);
        label.text = String(sec)
        bg.addChild(label)
        label.run(.repeatForever(.group([
            .wait(forDuration: 1),
            .run {
                let timeLeft = Int(label.text!)!
                if timeLeft == 0 {
                    finish()
                } else {
                    if timeLeft <= 10 {
                        label.fontColor = .green
                    }
                    label.text = String(timeLeft - 1)
                    tick(timeLeft)
                }
            }
        ])))
    }
    
    func overlay(text: String, color: UIColor, completion: EmptyClosure? = nil) {
        let bg = SKSpriteNode(color: color, size: .init(width: size.width, height: size.height))
        bg.position = .init(x: self.size.width / 2, y: self.size.height / 2)
        bg.zPosition = CGFloat.greatestFiniteMagnitude
        addChild(bg)
        let label = SKLabelNode()
        label.numberOfLines = 0
        
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([.foregroundColor: UIColor.white, .font : UIFont.monospacedSystemFont(ofSize: 20, weight: .black)], range: range)
        label.attributedText = attrString
        
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        bg.addChild(label)
        
        bg.alpha = 0
        
        bg.run(
            .fadeIn(withDuration: 1.5)
        ) {
            completion?()
        }
    }
    
    func taskSuccededOveralay(completion: EmptyClosure? = nil) {
        overlay(text: NSLocalizedString("task_completed", comment: ""), color: .blue.withAlphaComponent(0.9), completion: completion)
    }
    
    func taskFailedOveralay(completion: EmptyClosure? = nil) {
        overlay(text: NSLocalizedString("task_failed", comment: ""), color: .red.withAlphaComponent(0.9), completion: completion)
    }
    
    func explode(node: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = node.position
            addChild(emitter)
        }
        node.removeFromParent()
    }
}
