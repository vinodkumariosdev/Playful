// TalkingTomManager.swift
// Provides simple text-to-speech "Talking Tom" style voice for the KidLearn app.

import AVFoundation

/// Manager providing kid‑friendly speech feedback ("Talking Tom" style).
/// Features:
/// - Toggle enable/disable via UserDefaults.
/// - Random encouragement phrases.
/// - Customizable rate & pitch.
/// - Ability to stop current speaking.
/// - Simple phrase library for reuse.
final class TalkingTomManager: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = TalkingTomManager()
    private let synthesizer = AVSpeechSynthesizer()
    private override init() {
        super.init()
        synthesizer.delegate = self
    }
    private let defaults = UserDefaults.standard
    private let toggleKey = "TalkingTomEnabled"
    private var audioSessionConfigured = false

    // MARK: - Phrase Library
    private let encouragements = [
        "Great job!",
        "Keep going!",
        "You're awesome!",
        "Nice work!",
        "Fantastic!",
        "Brilliant!"
    ]

    /// Spoken when a category is selected (fallback if needed)
    private let defaultSelectionPrefix = "You chose"

    // MARK: - Configurable Properties
    /// Speech rate multiplier (0.3 - 0.7 recommended)
    var rateMultiplier: Float {
        get { defaults.object(forKey: "TomRateMultiplier") as? Float ?? 0.5 }
        set { defaults.set(newValue, forKey: "TomRateMultiplier") }
    }
    /// Pitch (0.5 - 2.0)
    var pitchMultiplier: Float {
        get { defaults.object(forKey: "TomPitchMultiplier") as? Float ?? 1.2 }
        set { defaults.set(newValue, forKey: "TomPitchMultiplier") }
    }

    /// Optional custom voice identifier (e.g. from AVSpeechSynthesisVoice.speechVoices())
    var voiceIdentifier: String? {
        get { defaults.string(forKey: "TomVoiceIdentifier") }
        set { defaults.set(newValue, forKey: "TomVoiceIdentifier") }
    }

    /// Returns whether Talking Tom voice is enabled. Defaults to true.
    var isEnabled: Bool {
        get { defaults.object(forKey: toggleKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: toggleKey) }
    }
    
    /// Speak the given text using a friendly voice.
    func speak(text: String) {
        guard isEnabled else { return }
        configureAudioSessionIfNeeded()
        print("[TalkingTom] Speaking: \(text)")
        let utterance = AVSpeechUtterance(string: text)
        // Choose user-specified voice or default en-US
        if let id = voiceIdentifier, let customVoice = AVSpeechSynthesisVoice(identifier: id) {
            utterance.voice = customVoice
        } else if let fallback = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = fallback
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rateMultiplier
        utterance.pitchMultiplier = pitchMultiplier
        synthesizer.speak(utterance)
    }

    /// Convenience to speak a category selection.
    func speakCategory(_ title: String) {
        guard !title.isEmpty else { return }
        speak(text: "\(defaultSelectionPrefix) \(title)")
    }

    /// Speak a random encouragement phrase.
    func speakEncouragement() {
        if let phrase = encouragements.randomElement() {
            speak(text: phrase)
        }
    }

    /// Stop current speech immediately.
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    private func configureAudioSessionIfNeeded() {
        guard !audioSessionConfigured else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            audioSessionConfigured = true
            print("[TalkingTom] Audio session configured")
        } catch {
            print("[TalkingTom] Failed to configure audio session: \(error)")
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("[TalkingTom] Finished utterance")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("[TalkingTom] Cancelled utterance")
    }
}
