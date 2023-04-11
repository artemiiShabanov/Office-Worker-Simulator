import UIKit

class Computer {
    private let screenContainer: UIView
    private let keyboardContainer: UIView
    
    private var display: Display?
    private var keyboard: Keybaord?
    private var program: Program?
    
    init(screenContainer: UIView, keyboardContainer: UIView) {
        self.screenContainer = screenContainer
        self.keyboardContainer = keyboardContainer
    }
    
    func startup(program: Program) {
        display?.clear()
        
        self.program = program
        
        keyboard?.switch(keys: program.keys)
        
        if let window = display?.provideScreen() {
            program.render(in: window)
        }
    }
    
    func plugIn(display: Display) {
        if self.display != nil { unplugDisplay() }
        self.display = display
        display.render(in: screenContainer)
        if let program {
            program.render(in: display.provideScreen())
        }
    }
    
    func unplugDisplay() {
        screenContainer.subviews.forEach { $0.removeFromSuperview() }
        display = nil
    }
    
    func plugIn(keyboard: Keybaord) {
        if self.keyboard != nil { unplugKeyboard() }
        self.keyboard = keyboard
        keyboard.render(in: keyboardContainer)
        self.keyboard?.onTap = { [weak self] in
            self?.input(key: $0)
        }
        if let program {
            self.keyboard?.switch(keys: program.keys)
        }
    }
    
    func unplugKeyboard() {
        keyboardContainer.subviews.forEach { $0.removeFromSuperview() }
        keyboard = nil
    }
}

// MARK: - Private

private extension Computer {
    func input(key: KeyType) {
        program?.react(toInput: key)
    }
}
