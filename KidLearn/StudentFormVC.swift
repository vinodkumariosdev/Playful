import UIKit

class StudentFormVC: UIViewController {
    var onSave: ((Student) -> Void)?
    private var existing: Student?

    private let nameField = UITextField()
    private let ageField = UITextField()
    private let genderPicker = UIPickerView()
    private let avatarField = UITextField()
    private let avatarPreview = UILabel()
    private let emojiScroll = UIScrollView()

    private let genders = ["Male", "Female", "Other"]
    private var selectedGender: String = "Male"
    private let emojiOptions: [String] = ["🐻","🐶","🐱","🐼","🦊","🐵","🐤","🦁","🐯","🐸","🦄","🐷","🐰","🐨","👶"]
    private var selectedAvatar: String = "👶"

    init(student: Student? = nil) {
        self.existing = student
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = existing == nil ? "Add Student" : "Edit Student"
        view.backgroundColor = .systemGroupedBackground
        setupFields()
        setupNavBar()
        if let s = existing { populate(with: s) }
    }

    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
    }

    private func setupFields() {
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.placeholder = "Child's name"
        nameField.borderStyle = .roundedRect
        view.addSubview(nameField)

        ageField.translatesAutoresizingMaskIntoConstraints = false
        ageField.placeholder = "Age (1-12)"
        ageField.borderStyle = .roundedRect
        ageField.keyboardType = .numberPad
        view.addSubview(ageField)

        avatarPreview.translatesAutoresizingMaskIntoConstraints = false
        avatarPreview.font = UIFont.systemFont(ofSize: 48)
        avatarPreview.textAlignment = .center
        avatarPreview.text = selectedAvatar
        avatarPreview.layer.cornerRadius = 10
        avatarPreview.clipsToBounds = true
        view.addSubview(avatarPreview)

        emojiScroll.translatesAutoresizingMaskIntoConstraints = false
        emojiScroll.showsHorizontalScrollIndicator = false
        view.addSubview(emojiScroll)

        genderPicker.translatesAutoresizingMaskIntoConstraints = false
        genderPicker.dataSource = self
        genderPicker.delegate = self
        view.addSubview(genderPicker)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),

            ageField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            ageField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            ageField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            avatarPreview.topAnchor.constraint(equalTo: ageField.bottomAnchor, constant: 14),
            avatarPreview.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            avatarPreview.widthAnchor.constraint(equalToConstant: 88),
            avatarPreview.heightAnchor.constraint(equalToConstant: 88),

            emojiScroll.leadingAnchor.constraint(equalTo: avatarPreview.trailingAnchor, constant: 12),
            emojiScroll.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            emojiScroll.centerYAnchor.constraint(equalTo: avatarPreview.centerYAnchor),
            emojiScroll.heightAnchor.constraint(equalToConstant: 88),

            genderPicker.topAnchor.constraint(equalTo: avatarPreview.bottomAnchor, constant: 12),
            genderPicker.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            genderPicker.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            genderPicker.heightAnchor.constraint(equalToConstant: 120)
        ])

        setupEmojiOptions()
    }

    private func populate(with s: Student) {
        nameField.text = s.name
        ageField.text = "\(s.age)"
        selectedAvatar = s.avatarEmoji
        avatarPreview.text = selectedAvatar
        if let idx = genders.firstIndex(of: s.gender) { genderPicker.selectRow(idx, inComponent: 0, animated: false); selectedGender = s.gender }
    }

    @objc private func cancel() {
        dismiss(animated: true)
    }

    @objc private func save() {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { showError("Please enter a name"); return }
        guard let ageText = ageField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let age = Int(ageText), (1...12).contains(age) else { showError("Age must be a number between 1 and 12"); return }
        let avatar = selectedAvatar

        let student = Student(name: name, age: age, gender: selectedGender, avatarEmoji: avatar)
        onSave?(student)
        dismiss(animated: true)
    }

    private func showError(_ message: String) {
        let ac = UIAlertController(title: "Invalid", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

extension StudentFormVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { genders.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { genders[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { selectedGender = genders[row] }
}

// MARK: - Emoji Picker
private extension StudentFormVC {
    func setupEmojiOptions() {
        var x: CGFloat = 8
        let spacing: CGFloat = 10
        for (i, e) in emojiOptions.enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(e, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 36)
            b.frame = CGRect(x: x, y: 8, width: 64, height: 72)
            b.tag = i
            b.addTarget(self, action: #selector(emojiTapped(_:)), for: .touchUpInside)
            emojiScroll.addSubview(b)
            x += 64 + spacing
        }
        emojiScroll.contentSize = CGSize(width: x, height: 88)
    }

    @objc func emojiTapped(_ sender: UIButton) {
        guard sender.tag >= 0 && sender.tag < emojiOptions.count else { return }
        selectedAvatar = emojiOptions[sender.tag]
        avatarPreview.text = selectedAvatar
    }
}

