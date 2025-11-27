
import UIKit
import AVFoundation

final class SineWavePlayer {
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var theta: Double = 0

    func play(frequency: Double = 880, duration: TimeInterval = 0.25, amplitude: Double = 0.25) {
        stop()

        let sampleRate = 44100.0
        let twoPi = 2.0 * Double.pi
        let increment = twoPi * frequency / sampleRate

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let sampleVal = Float(sin(self.theta) * amplitude)
                self.theta += increment
                if self.theta > twoPi { self.theta -= twoPi }
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = sampleVal
                }
            }
            return noErr
        }

        engine.attach(sourceNode!)
        engine.connect(sourceNode!, to: engine.mainMixerNode, format: format)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            print("SineWavePlayer failed to start: \(error)")
            return
        }

        // stop after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.stop()
        }
    }

    func stop() {
        if let node = sourceNode {
            engine.disconnectNodeInput(node)
            engine.detach(node)
            sourceNode = nil
        }
        if engine.isRunning {
            engine.stop()
        }
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // ignore
        }
    }
}

class LoginVC: UIViewController, UITextFieldDelegate {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let startButton = UIButton(type: .system)
    private let parentButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    private let sinePlayer = SineWavePlayer()
    private let speech = AVSpeechSynthesizer()
    private var didAutoLogin = false

    private func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let system = UIFont.systemFont(ofSize: size, weight: weight)
        if let desc = system.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: desc, size: size)
        }
        return system
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupGradientBackground()
        setupLabels()
        setupFields()
        setupButtons()
        animateBalloons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoFillIfSaved()
    }

    private func autoFillIfSaved() {
        guard !didAutoLogin else { return }
        didAutoLogin = true
        guard let user = UserDefaults.standard.dictionary(forKey: "KidzzUser") as? [String: String],
              let name = user["name"], let pass = user["password"] else { return }

        // prefill fields only (do not navigate)
        usernameField.text = name
        passwordField.text = pass

        // subtle welcome: play a short chime and speak a friendly greeting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
           // AudioManager.shared.playJingle(named: "success_jingle.wav")
            self.speak("Welcome back \(name)!")
        }
    }

    private func setupFields() {
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        usernameField.placeholder = "Name (e.g. Lily)"
        usernameField.font = roundedFont(size: 20, weight: .semibold)
        usernameField.backgroundColor = UIColor(white: 1.0, alpha: 0.85)
        usernameField.layer.cornerRadius = 14
        usernameField.layer.masksToBounds = true
        usernameField.textAlignment = .center
        usernameField.delegate = self
        usernameField.autocapitalizationType = .words
        usernameField.returnKeyType = .next
        usernameField.accessibilityLabel = "Child name"
        usernameField.leftView = emojiLeftView("🧒")
        usernameField.leftViewMode = .always

        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.placeholder = "Password"
        passwordField.font = roundedFont(size: 20, weight: .semibold)
        passwordField.backgroundColor = UIColor(white: 1.0, alpha: 0.85)
        passwordField.layer.cornerRadius = 14
        passwordField.layer.masksToBounds = true
        passwordField.textAlignment = .center
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        passwordField.returnKeyType = .done
        passwordField.accessibilityLabel = "Password"
        passwordField.leftView = emojiLeftView("🔒")
        passwordField.leftViewMode = .always

        view.addSubview(usernameField)
        view.addSubview(passwordField)

        NSLayoutConstraint.activate([
            usernameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.78),
            usernameField.heightAnchor.constraint(equalToConstant: 56),

            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 12),
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.widthAnchor.constraint(equalTo: usernameField.widthAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func emojiLeftView(_ emoji: String) -> UIView {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: 28)
        label.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        label.textAlignment = .center
        return label
    }

    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.systemPink.cgColor, UIColor.systemYellow.cgColor, UIColor.systemTeal.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        gradient.masksToBounds = true
    }

    private func setupLabels() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Kidzz"
        titleLabel.font = roundedFont(size: 56, weight: .heavy)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.accessibilityTraits = .header

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Fun Learning"
        subtitleLabel.font = roundedFont(size: 18, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor(white: 1.0, alpha: 0.9)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupButtons() {
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = roundedFont(size: 34, weight: .bold)
        startButton.backgroundColor = UIColor(red: 0.98, green: 0.57, blue: 0.12, alpha: 1)
        startButton.layer.cornerRadius = 28
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 0.2
        startButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        parentButton.translatesAutoresizingMaskIntoConstraints = false
        parentButton.setTitle("Parent", for: .normal)
        parentButton.setTitleColor(.white, for: .normal)
        parentButton.titleLabel?.font = roundedFont(size: 22, weight: .semibold)
        parentButton.backgroundColor = UIColor(red: 0.11, green: 0.56, blue: 0.95, alpha: 1)
        parentButton.layer.cornerRadius = 22
        parentButton.layer.shadowColor = UIColor.black.cgColor
        parentButton.layer.shadowOpacity = 0.15
        parentButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        parentButton.addTarget(self, action: #selector(parentTapped), for: .touchUpInside)

        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = roundedFont(size: 18, weight: .semibold)
        registerButton.backgroundColor = UIColor(red: 0.95, green: 0.45, blue: 0.65, alpha: 1)
        registerButton.layer.cornerRadius = 20
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOpacity = 0.12
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        // Use a horizontal stack for Parent & Register for better alignment on all device widths
        let duoStack = UIStackView(arrangedSubviews: [parentButton, registerButton])
        duoStack.translatesAutoresizingMaskIntoConstraints = false
        duoStack.axis = .horizontal
        duoStack.distribution = .fillEqually
        duoStack.alignment = .center
        duoStack.spacing = 16

        view.addSubview(startButton)
        view.addSubview(duoStack)

        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            startButton.heightAnchor.constraint(equalToConstant: 84),

            duoStack.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 18),
            duoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            duoStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            parentButton.heightAnchor.constraint(equalToConstant: 52),
            registerButton.heightAnchor.constraint(equalTo: parentButton.heightAnchor)
        ])
    }

    private func animateBalloons() {
        let emojis = ["🎈","🐣","🎵","🧸","🌟"]
        for i in 0..<5 {
            let label = UILabel()
            label.text = emojis[i % emojis.count]
            label.font = UIFont.systemFont(ofSize: 44)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)

            let startX = CGFloat(30 + i * 60)
            label.center = CGPoint(x: startX, y: view.bounds.height + 60)

            // place near bottom
            label.frame = CGRect(x: startX, y: view.bounds.height + CGFloat(i * 40), width: 60, height: 60)

            let delay = Double(i) * 0.6
            let duration = 6.0 + Double(i)
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat], animations: {
                label.frame.origin.y = -120
                label.alpha = 0.9
            }, completion: nil)
        }
    }

    @objc private func startTapped() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        animateButtonPress(startButton)

        // validate fields
        let name = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pass = passwordField.text ?? ""
        guard !name.isEmpty, !pass.isEmpty else {
                // error sound + speech (use bundled jingle if available)
                AudioManager.shared.playJingle(named: "error_jingle.wav")
                speak("Please enter name and password")
            return
        }

            // success sound + speech
            AudioManager.shared.playJingle(named: "success_jingle.wav")
            speak("Welcome \(name)! Let's play!")

            // navigate to main screen
            let main = MainScreen(name: name)
            navigationController?.pushViewController(main, animated: true)
    }

    @objc private func parentTapped() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        animateButtonPress(parentButton)

        let alert = UIAlertController(title: "Parent Access", message: "Enter 4-digit PIN", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "PIN"
            tf.isSecureTextEntry = true
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let code = alert.textFields?.first?.text else { return }
            self?.checkParentPin(code: code)
        }))
        present(alert, animated: true)
    }

    private func checkParentPin(code: String) {
        if code == "1234" {
            AudioManager.shared.playJingle(named: "success_jingle.wav")
            speak("Welcome parent. Access granted.")
            // TODO: present parent settings
        } else {
            AudioManager.shared.playJingle(named: "error_jingle.wav")
            speak("Incorrect PIN. Try again.")
        }
    }

    @objc private func registerTapped() {
        let reg = RegisterVC()
        navigationController?.pushViewController(reg, animated: true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else {
            passwordField.resignFirstResponder()
            startTapped()
        }
        return true
    }

    private func animateButtonPress(_ button: UIView) {
        UIView.animate(withDuration: 0.08, animations: {
            button.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.18) {
                button.transform = .identity
            }
        })
    }

    private func speak(_ text: String) {
        guard !speech.isSpeaking else { return }
        let utter = AVSpeechUtterance(string: text)
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        utter.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        speech.speak(utter)
    }
}

