import SpriteKit

enum Textures {
    enum Tasks {
        enum Typing {
            static let bg = SKTexture(imageNamed: "typing/bg")
            static let circle = SKTexture(imageNamed: "typing/circle")
            static let square = SKTexture(imageNamed: "typing/square")
        }
        enum Clicking {
                static let bg = SKTexture(imageNamed: "clicking/bg")
            static let coursor = SKTexture(imageNamed: "clicking/coursor")
            static let coursorClick = SKTexture(imageNamed: "clicking/coursor_click")
            static let buttons = (1...4).map { SKTexture(imageNamed: "clicking/buttons/\($0)") }
            static let bombButtons = (1...4).map { SKTexture(imageNamed: "clicking/buttons/\($0)_b") }
        }
        enum Sorting {
            static let bg = SKTexture(imageNamed: "sorting/bg")
            static let bin = SKTexture(imageNamed: "sorting/bin")
            static let folderLeft = SKTexture(imageNamed: "sorting/folder_left")
            static let folderRight = SKTexture(imageNamed: "sorting/folder_right")
            static let buttons = Dictionary(uniqueKeysWithValues: (1...5).flatMap { index in
                ["b", "g", "o", "p", "r", "y"].map { color in
                    let id = ("\(index)_\(color)")
                    return (id, SKTexture(imageNamed: "sorting/files/\(id)"))
                }
            })
        }
    }
}
