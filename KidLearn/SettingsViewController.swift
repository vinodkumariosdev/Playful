import UIKit
import AVFoundation

final class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    private let enableSwitch = UISwitch()
    private let rateSlider = UISlider()
    private let pitchSlider = UISlider()
    private let voicePicker = UIPickerView()
    private var voices: [AVSpeechSynthesisVoice] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Talking Tom Settings"
        view.backgroundColor = .systemBackground
        setupData()
        setupUI()
    }

    private func setupData() {
        voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }
    }

    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Enable section
        let enableRow = row(title: "Enable Talking Tom", control: enableSwitch)
        enableSwitch.isOn = TalkingTomManager.shared.isEnabled
        enableSwitch.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(enableRow)

        // Rate
        rateSlider.minimumValue = 0.3
        rateSlider.maximumValue = 0.7
        rateSlider.value = TalkingTomManager.shared.rateMultiplier
        rateSlider.addTarget(self, action: #selector(rateChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(row(title: "Rate", control: rateSlider))

        // Pitch
        pitchSlider.minimumValue = 0.5
        pitchSlider.maximumValue = 2.0
        pitchSlider.value = TalkingTomManager.shared.pitchMultiplier
        pitchSlider.addTarget(self, action: #selector(pitchChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(row(title: "Pitch", control: pitchSlider))

        // Voice picker
        voicePicker.dataSource = self
        voicePicker.delegate = self
        voicePicker.translatesAutoresizingMaskIntoConstraints = false
        let voiceContainer = UIView()
        let voiceLabel = UILabel()
        voiceLabel.text = "Voice"
        voiceLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        voiceLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceContainer.addSubview(voiceLabel)
        voiceContainer.addSubview(voicePicker)
        voicePicker.topAnchor.constraint(equalTo: voiceLabel.bottomAnchor, constant: 8).isActive = true
        voicePicker.leadingAnchor.constraint(equalTo: voiceContainer.leadingAnchor).isActive = true
        voicePicker.trailingAnchor.constraint(equalTo: voiceContainer.trailingAnchor).isActive = true
        voicePicker.heightAnchor.constraint(equalToConstant: 140).isActive = true
        voiceLabel.topAnchor.constraint(equalTo: voiceContainer.topAnchor).isActive = true
        voiceLabel.leadingAnchor.constraint(equalTo: voiceContainer.leadingAnchor).isActive = true
        stack.addArrangedSubview(voiceContainer)

        // Close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(close))

        // Preselect current voice
        if let id = TalkingTomManager.shared.voiceIdentifier, let idx = voices.firstIndex(where: { $0.identifier == id }) {
            voicePicker.selectRow(idx, inComponent: 0, animated: false)
        }
    }

    private func row(title: String, control: UIView) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        control.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        container.addSubview(control)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            control.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            control.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        return container
    }

    // MARK: Actions
    @objc private func toggleChanged(_ sender: UISwitch) {
        TalkingTomManager.shared.isEnabled = sender.isOn
    }
    @objc private func rateChanged(_ sender: UISlider) {
        TalkingTomManager.shared.rateMultiplier = sender.value
    }
    @objc private func pitchChanged(_ sender: UISlider) {
        TalkingTomManager.shared.pitchMultiplier = sender.value
    }
    @objc private func close() { dismiss(animated: true) }

    // MARK: Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { voices.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let v = voices[row]
        return "\(v.language) - \(v.name)"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let v = voices[row]
        TalkingTomManager.shared.voiceIdentifier = v.identifier
        TalkingTomManager.shared.speakEncouragement()
    }
}
