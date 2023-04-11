import UIKit
import SPConfetti

protocol GameDelegate: AnyObject {
    func changed(style: OfficeStyle)
    func changedDifficulty()
}

class Game {
    enum Context {
        case welcome
        case booting
        case accessDenied
        case blueScreen
        case task(WorkTask)
        case taskSuccess(next: WorkTask)
        case tutorial(task: WorkTask)
        case fired
        case styleSetup
        case promotion
        case credits
        case cheatcodeInput
        case cheatcodeInputIncorrect
        case difficultySetup
    }
    
    private var workTasks: [WorkTask] = []
    private var currentTaskIndex = 0
    private let computer: Computer
    private var context: Context = .accessDenied {
        didSet {
            handleContextChange()
        }
    }
    
    weak var delegate: GameDelegate?
    
    init(computer: Computer) {
        self.computer = computer
    }
    
    func start() {
        workTasks = WorkTask.allCases.shuffled()
        currentTaskIndex = 0
        if !Preferences.shared.welcomed {
            context = .welcome
        } else {
            if Preferences.shared.signed {
                context = .booting
            } else {
                context = .accessDenied
            }
        }
    }
    
    func enterCheatCode() {
        context = .cheatcodeInput
    }
}

// MARK: - Private

private extension Game {
    func handleContextChange() {
        switch context {
        case .welcome:
            let p = WelcomeProgram()
            p.delegate = self
            computer.startup(program: p)
        case .booting:
            let p = FillCountProgram(
                text: NSLocalizedString("welcome_to_OWS", comment: ""),
                accentColor: .white,
                bgColor: .black,
                count: 6,
                offImage: UIImage(systemName: "square.dotted")!,
                onImage: UIImage(systemName: "dot.square")!
            )
            p.delegate = self
            computer.startup(program: p)
        case .accessDenied:
            let p = JustMessageProgram(bgColor: .black, text: NSLocalizedString("no_access", comment: ""), textColor: .white)
            p.delegate = self
            computer.startup(program: p)
        case .blueScreen:
            let p = BlueScreenProgram()
            p.delegate = self
            computer.startup(program: p)
        case .task(let task):
            let p = task.compile(with: Preferences.shared.difficulty)
            p.delegate = self
            computer.startup(program: p)
        case .taskSuccess(let next):
            let p = FillCountProgram(
                text: String(format: NSLocalizedString("next_task", comment: ""), next.description),
                accentColor: .white,
                bgColor: .black,
                count: 3
            )
            p.delegate = self
            computer.startup(program: p)
        case .tutorial(let task):
            let p = SlidesProgram(slides: task.tutorial)
            p.delegate = self
            computer.startup(program: p)
        case .fired:
            let p = FiredProgram()
            p.delegate = self
            computer.startup(program: p)
        case .styleSetup:
            let p = SelectionProgram(
                backColor: .blue,
                accentColor: .white,
                options: OfficeStyle.allCases.map(\.name)
            )
            p.delegate = self
            computer.startup(program: p)
        case .promotion:
            let p = JustMessageProgram(
                bgColor: .init(red: 255, green: 215, blue: 0, alpha: 1),
                text: String(
                    format: NSLocalizedString("promotion", comment: ""),
                    Preferences.shared.difficulty.name
                ),
                textColor: .black
            )
            p.delegate = self
            computer.startup(program: p)
            SPConfetti.startAnimating(.centerWidthToDown, particles: [.arc, .star, .triangle], duration: 2)
        case .credits:
            let p = TypingProgram(lines: [
                NSLocalizedString("credits_line1", comment: ""),
                NSLocalizedString("credits_line2", comment: ""),
                NSLocalizedString("credits_line3", comment: ""),
                NSLocalizedString("credits_line4", comment: "")
            ])
            p.delegate = self
            computer.startup(program: p)
        case .cheatcodeInput:
            let p = InputProgram(leftKey: "X", rightKey: "O")
            p.delegate = self
            computer.startup(program: p)
        case .cheatcodeInputIncorrect:
            let p = JustMessageProgram(
                bgColor: .white,
                text: NSLocalizedString("no_cheatcode", comment: ""),
                textColor: .red
            )
            p.delegate = self
            computer.startup(program: p)
        case .difficultySetup:
            let p = SelectionProgram(
                backColor: .brown,
                accentColor: .white,
                options: Difficulty.allCases.map(\.name)
            )
            p.delegate = self
            computer.startup(program: p)
        }
    }
}

// MARK: - WorkTaskProgramDelegate

extension Game: WorkTaskProgramDelegate {
    func finished(success: Bool) {
        guard case .task(_) = context else { assertionFailure(); return }
        if success {
            if currentTaskIndex == workTasks.count - 1 {
                if Preferences.shared.immortal {
                    context = .blueScreen
                    return
                }
                context = .promotion
                Preferences.shared.beat(difficulty: Preferences.shared.difficulty)
                Preferences.shared.difficulty = Preferences.shared.difficulty.next
                delegate?.changedDifficulty()
            } else {
                currentTaskIndex += 1
                context = .taskSuccess(next: workTasks[currentTaskIndex])
            }
        } else {
            context = .fired
        }
    }
}

// MARK: - JustMessageProgramDelegate

extension Game: JustMessageProgramDelegate {
    func tap(key: KeyType) {
        switch context {
        case .accessDenied:
            SoundPlayer.shared.play(sound: .accessDenied)
        case .promotion:
            context = .credits
        case .cheatcodeInputIncorrect:
            start()
        default:
            assertionFailure()
        }
    }
}

// MARK: - BlueScreenProgramDelegate

extension Game: BlueScreenProgramDelegate {
    func fixed() {
        guard case .blueScreen = context else { assertionFailure(); return }
        start()
    }
}

// MARK: - FiredProgramDelegate

extension Game: FiredProgramDelegate {
    func wantToRestart() {
        guard case .fired = context else { assertionFailure(); return }
        start()
    }
}

// MARK: - WelcomeProgramDelegate

extension Game: WelcomeProgramDelegate {
    func signed() {
        guard case .welcome = context else { assertionFailure(); return }
        context = .booting
    }
    
    func declined() {
        guard case .welcome = context else { assertionFailure(); return }
        context = .accessDenied
    }
}

// MARK: - SelectionProgramDelegate

extension Game: SelectionProgramDelegate {
    func selected(index: Int) {
        switch context {
        case .styleSetup:
            let style = OfficeStyle.allCases[index]
            Preferences.shared.officeStyle = style
            delegate?.changed(style: style)
        case .difficultySetup:
            let difficulty = Difficulty.allCases[index]
            Preferences.shared.difficulty = difficulty
            delegate?.changedDifficulty()
        default:
            assertionFailure()
        }
    }
    
    func exit() {
        switch context {
        case .styleSetup, .difficultySetup:
            start()
        default:
            assertionFailure()
        }
    }
}

// MARK: - TypingProgramDelegate

extension Game: TypingProgramDelegate {
    func finished() {
        switch context {
        case .credits:
            start()
        default:
            assertionFailure()
        }
    }
}

// MARK: - FillCountProgramDelegate

extension Game: FillCountProgramDelegate {
    func finishedCounting() {
        switch context {
        case .booting:
            context = .taskSuccess(next: workTasks[currentTaskIndex])
        case .taskSuccess(let next):
            if Preferences.shared.watchedTutorials.contains(next) {
                context = .task(next)
            } else {
                context = .tutorial(task: next)
                Preferences.shared.watchTutorial(for: next)
            }
        default:
            assertionFailure()
        }
    }
}

// MARK: - InputProgramDelegate

extension Game: InputProgramDelegate {
    func output(string: String) {
        switch context {
        case .cheatcodeInput:
            if string.count >= Cheatcode.length {
                for code in Cheatcode.allCases {
                    if string == code.command {
                        switch code {
                        case .immortality:
                            Preferences.shared.immortal.toggle()
                            start()
                        case .changeBG:
                            context = .styleSetup
                        case .changeDifficulty:
                            context = .difficultySetup
                        case .taskTyping:
                            context = .task(.typing)
                        case .taskSorting:
                            context = .task(.fileSort)
                        case .taskClicking:
                            context = .task(.clicks)
                        }
                        return
                    }
                }
                context = .cheatcodeInputIncorrect
            }
        default:
            assertionFailure()
        }
    }
}

// MARK: - SlidesProgramDelegate

extension Game: SlidesProgramDelegate {
    func lastSlideWatched() {
        guard case .tutorial(let task) = context else { assertionFailure(); return }
        context = .task(task)
    }
}
