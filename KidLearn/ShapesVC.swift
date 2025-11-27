import UIKit
import AVFoundation

final class ShapesViewController: UIViewController {
    private let speech = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupUI()
    }

    private func setupUI() {
        title = "Shapes"
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Shapes"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])

        // shapes with display name
        let shapes: [(emoji: String, name: String, sound: String?)] = [
            ("◯", "Circle", "shape_circle.wav"),
            ("⬛", "Square", "shape_square.wav"),
            ("△", "Triangle", "shape_triangle.wav"),
            ("⬟", "Pentagon", "shape_pentagon.wav"),
            ("★", "Star", "shape_star.wav"),
            ("✦", "Diamond", "shape_diamond.wav")
        ]

        let grid = UIStackView()
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.axis = .vertical
        grid.spacing = 12
        view.addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        let cols = 2
        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually
            for col in 0..<cols {
                let idx = row * cols + col
                if idx < shapes.count {
                    let item = shapes[idx]
                    let container = UIStackView()
                    container.axis = .vertical
                    container.alignment = .center
                    container.spacing = 8

                    let btn = UIButton(type: .system)
                    btn.translatesAutoresizingMaskIntoConstraints = false
                    btn.setTitle(item.emoji, for: .normal)
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 48)
                    btn.backgroundColor = UIColor(white: 1, alpha: 0.98)
                    btn.layer.cornerRadius = 14
                    btn.layer.shadowColor = UIColor.black.cgColor
                    btn.layer.shadowOpacity = 0.06
                    btn.layer.shadowOffset = CGSize(width: 0, height: 4)
                    btn.widthAnchor.constraint(equalToConstant: 120).isActive = true
                    btn.heightAnchor.constraint(equalToConstant: 120).isActive = true
                    btn.tag = idx
                    btn.addTarget(self, action: #selector(shapeTapped(_:)), for: .touchUpInside)

                    let nameLabel = UILabel()
                    nameLabel.text = item.name
                    nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                    nameLabel.textAlignment = .center

                    container.addArrangedSubview(btn)
                    container.addArrangedSubview(nameLabel)
                    rowStack.addArrangedSubview(container)
                } else {
                    let spacer = UIView()
                    rowStack.addArrangedSubview(spacer)
                }
            }
            grid.addArrangedSubview(rowStack)
        }
    }

    @objc private func shapeTapped(_ sender: UIButton) {
        let idx = sender.tag
        let names = ["Circle","Square","Triangle","Pentagon","Star","Diamond"]
        guard idx >= 0 && idx < names.count else { return }
        let name = names[idx]
        // speak the shape name
        if speech.isSpeaking { speech.stopSpeaking(at: .immediate) }
        let utt = AVSpeechUtterance(string: name)
        utt.voice = AVSpeechSynthesisVoice(language: "en-US")
        utt.rate = 0.45
        speech.speak(utt)

        // try to play a specific shape sound if present
        let filename = "shape_\(name.lowercased()).wav"
        AudioManager.shared.playJingle(named: filename)
    }
}
