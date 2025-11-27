import UIKit
import AVFoundation

class RegisterVC: UIViewController, UITextFieldDelegate {

    private let titleLabel = UILabel()
    private let nameField = UITextField()
    private let ageField = UITextField()
    private let genderControl = UISegmentedControl(items: ["Boy", "Girl"])
    private let passwordField = UITextField()
    private let registerButton = UIButton(type: .system)
    private let speech = AVSpeechSynthesizer()

    private var confettiLayer: CAEmitterLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTitle()
        setupFields()
        setupButton()
        startFloatingEmojis()
    }

    private func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let system = UIFont.systemFont(ofSize: size, weight: weight)
        if let desc = system.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: desc, size: size)
        }
        return system
    }

    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor, UIColor.systemOrange.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Create Account"
        titleLabel.font = roundedFont(size: 36, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupFields() {
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.placeholder = "Child name"
        nameField.font = roundedFont(size: 18, weight: .semibold)
        nameField.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        nameField.layer.cornerRadius = 14
        nameField.layer.masksToBounds = true
        nameField.textAlignment = .center
        nameField.returnKeyType = .next
        nameField.delegate = self
        nameField.leftView = makeEmojiLabel("🧸")
        nameField.leftViewMode = .always

        ageField.translatesAutoresizingMaskIntoConstraints = false
        ageField.placeholder = "Age"
        ageField.font = roundedFont(size: 18, weight: .regular)
        ageField.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        ageField.layer.cornerRadius = 14
        ageField.layer.masksToBounds = true
        ageField.textAlignment = .center
        ageField.keyboardType = .numberPad
        ageField.leftView = makeEmojiLabel("🎂")
        ageField.leftViewMode = .always

        genderControl.translatesAutoresizingMaskIntoConstraints = false
        genderControl.selectedSegmentIndex = 0

        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.placeholder = "Password"
        passwordField.font = roundedFont(size: 18, weight: .semibold)
        passwordField.backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        passwordField.layer.cornerRadius = 14
        passwordField.layer.masksToBounds = true
        passwordField.textAlignment = .center
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .done
        passwordField.delegate = self
        passwordField.leftView = makeEmojiLabel("🔒")
        passwordField.leftViewMode = .always

        // Use a vertical stack for consistent alignment & dynamic spacing across device sizes
        let formStack = UIStackView(arrangedSubviews: [nameField, ageField, genderControl, passwordField])
        formStack.axis = .vertical
        formStack.distribution = .fill
        formStack.alignment = .fill
        formStack.spacing = 12
        formStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(formStack)

        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            formStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.78),
            nameField.heightAnchor.constraint(equalToConstant: 52),
            ageField.heightAnchor.constraint(equalToConstant: 48),
            passwordField.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func makeEmojiLabel(_ emoji: String) -> UIView {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: 28)
        label.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        label.textAlignment = .center
        return label
    }

    private func setupButton() {
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.setTitle("Create Account", for: .normal)
        registerButton.backgroundColor = UIColor(red: 0.12, green: 0.72, blue: 0.45, alpha: 1)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = roundedFont(size: 20, weight: .bold)
        registerButton.layer.cornerRadius = 18
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOpacity = 0.18
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        view.addSubview(registerButton)
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            registerButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func startFloatingEmojis() {
        let emojis = ["🎈", "🌟", "🧸", "🐥", "🎵"]
        for i in 0..<6 {
            let label = UILabel()
            label.text = emojis[i % emojis.count]
            label.font = UIFont.systemFont(ofSize: 36)
            label.alpha = 0.9
            let startX = CGFloat(30 + (i * 50))
            label.frame = CGRect(x: startX, y: view.bounds.height + CGFloat(i * 10), width: 60, height: 60)
            view.addSubview(label)

            let delay = Double(i) * 0.5
            let duration = 6.0 + Double(i)
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat], animations: {
                label.frame.origin.y = -120
                label.alpha = 0.95
            }, completion: nil)
        }
    }

    @objc private func registerTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let age = ageField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pass = passwordField.text ?? ""
        guard !name.isEmpty, !age.isEmpty, !pass.isEmpty else {
            AudioManager.shared.playJingle(named: "error_jingle.wav")
            animateButtonError()
            showAnimatedAlert(title: "Missing Info", message: "Please fill all fields")
            return
        }

        // Success: play jingle, burst confetti, speak, then navigate
        AudioManager.shared.playJingle(named: "success_jingle.wav")
        triggerConfetti()
        speak("Account created. Welcome \(name)!")

        // persist user to UserDefaults
        let gender = genderControl.selectedSegmentIndex == 0 ? "Boy" : "Girl"
        let user: [String: String] = ["name": name, "age": age, "gender": gender, "password": pass]
        UserDefaults.standard.set(user, forKey: "KidzzUser")

        // small scale animation
        UIView.animate(withDuration: 0.12, animations: {
            self.registerButton.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.18) {
                self.registerButton.transform = .identity
            }
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let main = MainScreen(name: name)
            self.navigationController?.pushViewController(main, animated: true)
        }
    }

    private func animateButtonError() {
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                self.registerButton.transform = CGAffineTransform(translationX: -8, y: 0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.registerButton.transform = CGAffineTransform(translationX: 8, y: 0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.registerButton.transform = CGAffineTransform(translationX: -6, y: 0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.registerButton.transform = .identity
            }
        }, completion: nil)
    }

    private func triggerConfetti() {
        confettiLayer?.removeFromSuperlayer()
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.size.width, height: 1)

        var cells: [CAEmitterCell] = []
        for color in [UIColor.systemYellow, UIColor.systemPink, UIColor.systemTeal, UIColor.systemOrange, UIColor.systemGreen] {
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 4.0
            cell.velocity = 200
            cell.velocityRange = 80
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi/4
            cell.spin = 3
            cell.spinRange = 2
            cell.scale = 0.6
            cell.scaleRange = 0.3
            cell.color = color.cgColor
            cell.contents = makeConfettiImage().cgImage
            cells.append(cell)
        }
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
        confettiLayer = emitter

        // stop after short burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            emitter.birthRate = 0
        }
    }

    private func makeConfettiImage() -> UIImage {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.white.cgColor)
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(ovalIn: rect)
        path.fill()
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }

    // MARK: - Animated popup alert
    private func showAnimatedAlert(title: String?, message: String) {
        DispatchQueue.main.async {
            let overlay = UIView(frame: self.view.bounds)
            overlay.backgroundColor = UIColor(white: 0, alpha: 0.45)
            overlay.alpha = 0

            let card = UIView()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.backgroundColor = .white
            card.layer.cornerRadius = 16
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.2
            card.layer.shadowOffset = CGSize(width: 0, height: 6)

            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            titleLabel.textAlignment = .center

            let msgLabel = UILabel()
            msgLabel.translatesAutoresizingMaskIntoConstraints = false
            msgLabel.text = message
            msgLabel.font = UIFont.systemFont(ofSize: 16)
            msgLabel.numberOfLines = 0
            msgLabel.textAlignment = .center

            let okButton = UIButton(type: .system)
            okButton.translatesAutoresizingMaskIntoConstraints = false
            okButton.setTitle("OK", for: .normal)
            okButton.setTitleColor(.white, for: .normal)
            okButton.backgroundColor = UIColor(red: 0.12, green: 0.6, blue: 0.95, alpha: 1)
            okButton.layer.cornerRadius = 12

            overlay.addSubview(card)
            card.addSubview(titleLabel)
            card.addSubview(msgLabel)
            card.addSubview(okButton)

            self.view.addSubview(overlay)

            NSLayoutConstraint.activate([
                card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                card.widthAnchor.constraint(equalTo: overlay.widthAnchor, multiplier: 0.78),
                
                titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
                titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

                msgLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                msgLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                msgLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

                okButton.topAnchor.constraint(equalTo: msgLabel.bottomAnchor, constant: 14),
                okButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                okButton.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.5),
                okButton.heightAnchor.constraint(equalToConstant: 44),
                okButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
            ])

            // entrance animation
            card.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            overlay.alpha = 0
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                overlay.alpha = 1
            }, completion: nil)
            UIView.animate(withDuration: 0.36, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.2, options: [], animations: {
                card.transform = .identity
            }, completion: nil)

            okButton.addTarget(self, action: #selector(self.dismissAnimatedAlert(_:)), for: .touchUpInside)

            // store the overlay as associated object by tag so dismiss can find it
            overlay.tag = 99111
        }
    }

    @objc private func dismissAnimatedAlert(_ sender: UIButton) {
        // find overlay by tag
        guard let overlay = self.view.viewWithTag(99111) else { return }
        // animate out
        if let card = overlay.subviews.first {
            UIView.animate(withDuration: 0.22, animations: {
                card.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                overlay.alpha = 0
            }, completion: { _ in
                overlay.removeFromSuperview()
            })
        } else {
            overlay.removeFromSuperview()
        }
    }

    private func speak(_ text: String) {
        guard !speech.isSpeaking else { return }
        let utter = AVSpeechUtterance(string: text)
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        utter.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        speech.speak(utter)
    }

    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            ageField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            registerTapped()
        }
        return true
    }
}
