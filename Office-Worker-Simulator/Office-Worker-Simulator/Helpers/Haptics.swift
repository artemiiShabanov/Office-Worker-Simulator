import UIKit
import AudioToolbox

final class Haptics {
    enum FeedbackType {
        case soft
        case light
        case rigid
        case medium
        case heavy
        
        case error
        case warning
        case success
        
        case old
    }
    
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notif = UINotificationFeedbackGenerator()
    
    static let shared = Haptics()
    private init() {}
    
    func play(type: FeedbackType) {
        switch type {
        case .soft:
            soft.impactOccurred()
        case .light:
            light.impactOccurred()
        case .rigid:
            rigid.impactOccurred()
        case .medium:
            medium.impactOccurred()
        case .heavy:
            heavy.impactOccurred()
        case .error:
            notif.notificationOccurred(.error)
        case .warning:
            notif.notificationOccurred(.warning)
        case .success:
            notif.notificationOccurred(.success)
        case .old:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
