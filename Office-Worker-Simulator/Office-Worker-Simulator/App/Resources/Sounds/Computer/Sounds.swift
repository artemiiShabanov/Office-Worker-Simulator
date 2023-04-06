import AVFoundation


enum Sound: CaseIterable {
    case oldKey
}

fileprivate extension Sound {
    var file: URL {
        let resource: String
        switch self {
        case .oldKey:
            resource = "oldKey.wav"
        }
        return URL(fileURLWithPath: Bundle.main.path(forResource: resource, ofType: nil)!)
    }
}

final class SoundPlayer {
    private var ids: [Sound: SystemSoundID] = [:]
    private init() {
        for sound in Sound.allCases {
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(sound.file as CFURL, &soundID)
            ids[sound] = soundID
        }
    }
    static let shared = SoundPlayer()
    
    func play(sound: Sound) {
        guard let soundId = ids[sound] else { assertionFailure(); return }
        AudioServicesPlaySystemSound(soundId)
    }
}

