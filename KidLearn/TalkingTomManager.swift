// TalkingTomManager.swift
// Provides simple text-to-speech "Talking Tom" style voice for the KidLearn app.

import AVFoundation

final class TalkingTomManager {
    static let shared = TalkingTomManager()
    private let synthesizer = AVSpeechSynthesizer()
    private init() {}
    private let defaults = UserDefaults.standard
    private let toggleKey = "TalkingTomEnabled"

    /// Returns whether Talking Tom voice is enabled. Defaults to true.
    var isEnabled: Bool {
        get { defaults.object(forKey: toggleKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: toggleKey) }
    }
    
    /// Speak the given text using a friendly voice.
    func speak(text: String) {
        guard isEnabled else { return }
        let utterance = AVSpeechUtterance(string: text)
        // Choose a pleasant voice; fallback to default if not available.
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.5
        utterance.pitchMultiplier = 1.2
        synthesizer.speak(utterance)
    }
}
