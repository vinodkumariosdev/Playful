import Foundation
import AVFoundation

final class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    private let sine = SineWavePlayer()

    private init() {}

    func playJingle(named name: String) {
        // attempt to load bundled jingle (e.g. success_jingle.wav) placed in app bundle
        if let url = Bundle.main.url(forResource: name, withExtension: nil) {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                player?.play()
                return
            } catch {
                print("AudioManager: failed to play \(name): \(error)")
            }
        }
        // fallback to simple sine chime
        switch name {
        case "success_jingle.wav", "success_jingle.mp3":
            sine.play(frequency: 880, duration: 0.35, amplitude: 0.28)
        case "error_jingle.wav", "error_jingle.mp3":
            sine.play(frequency: 220, duration: 0.35, amplitude: 0.22)
        default:
            sine.play(frequency: 660, duration: 0.28, amplitude: 0.25)
        }
    }
}
