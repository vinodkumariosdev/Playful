import UIKit

struct Student: Codable {
    var name: String
    var age: Int
    var gender: String
    var avatarEmoji: String
}

class StudentDetailsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var collectionView: UICollectionView!
    private var students: [Student] = []
    private let storageKey = "KidzzStudents"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "👪 Students"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        applyBackgroundGradient()
        setupCollection()
        setupAddButton()
        loadStudents()
    }

    private func applyBackgroundGradient() {
        let g = CAGradientLayer()
        g.frame = view.bounds
        g.colors = [UIColor(red: 0.99, green: 0.96, blue: 0.89, alpha: 1).cgColor,
                    UIColor(red: 0.95, green: 0.88, blue: 0.98, alpha: 1).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        let bg = UIView(frame: view.bounds)
        bg.layer.insertSublayer(g, at: 0)
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(bg, at: 0)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let padding: CGFloat = 16
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(StudentCell.self, forCellWithReuseIdentifier: StudentCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupAddButton() {
        let btn = UIButton(type: .system)
        btn.setTitle("+ Add Child", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.18, green: 0.64, blue: 0.56, alpha: 1)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.layer.cornerRadius = 14
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        btn.addTarget(self, action: #selector(addStudent), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }

    @objc private func addStudent() {
        let form = StudentFormVC()
        form.onSave = { [weak self] student in
            guard let self = self else { return }
            self.students.append(student)
            self.saveStudents()
            self.collectionView.reloadData()
        }
        let nav = UINavigationController(rootViewController: form)
        present(nav, animated: true)
    }

    private func loadStudents() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            students = try JSONDecoder().decode([Student].self, from: data)
            collectionView.reloadData()
        } catch {
            print("Failed to load students: \(error)")
        }
    }

    private func saveStudents() {
        do {
            let data = try JSONEncoder().encode(students)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save students: \(error)")
        }
    }

    // MARK: - Collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return students.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StudentCell.reuseIdentifier, for: indexPath) as? StudentCell else {
            return UICollectionViewCell()
        }
        let s = students[indexPath.item]
        cell.configure(with: s)
        // long press to delete/edit
        cell.onEdit = { [weak self] in
            self?.presentEdit(for: indexPath.item)
        }
        cell.onDelete = { [weak self] in
            self?.confirmDelete(index: indexPath.item)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        presentEdit(for: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let interItem: CGFloat = 12
        let columns: CGFloat = 2
        let totalSpacing = padding * 2 + (columns - 1) * interItem
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: floor(width), height: 140)
    }

    private func presentEdit(for index: Int) {
        let existing = students[index]
        let form = StudentFormVC(student: existing)
        form.onSave = { [weak self] updated in
            guard let self = self else { return }
            self.students[index] = updated
            self.saveStudents()
            self.collectionView.reloadData()
        }
        let nav = UINavigationController(rootViewController: form)
        present(nav, animated: true)
    }

    private func confirmDelete(index: Int) {
        let ac = UIAlertController(title: "Delete", message: "Remove this student?", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.students.remove(at: index)
            self.saveStudents()
            self.collectionView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

final class StudentCell: UICollectionViewCell {
    static let reuseIdentifier = "StudentCell"
    private let avatarContainer = UIView()
    private let avatar = UILabel()
    private let nameLabel = UILabel()
    private let ageChip = UILabel()
    private let genderChip = UILabel()
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 14
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 6)

        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.layer.cornerRadius = 32
        avatarContainer.clipsToBounds = true
        contentView.addSubview(avatarContainer)

        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.font = UIFont.systemFont(ofSize: 40)
        avatar.textAlignment = .center
        avatarContainer.addSubview(avatar)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        contentView.addSubview(nameLabel)

        ageChip.translatesAutoresizingMaskIntoConstraints = false
        ageChip.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        ageChip.textColor = .white
        ageChip.backgroundColor = UIColor(red: 0.95, green: 0.57, blue: 0.35, alpha: 1)
        ageChip.layer.cornerRadius = 10
        ageChip.clipsToBounds = true
        ageChip.textAlignment = .center
        ageChip.setContentHuggingPriority(.required, for: .horizontal)
        contentView.addSubview(ageChip)

        genderChip.translatesAutoresizingMaskIntoConstraints = false
        genderChip.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        genderChip.textColor = .white
        genderChip.backgroundColor = UIColor(red: 0.35, green: 0.66, blue: 0.95, alpha: 1)
        genderChip.layer.cornerRadius = 10
        genderChip.clipsToBounds = true
        genderChip.textAlignment = .center
        genderChip.setContentHuggingPriority(.required, for: .horizontal)
        contentView.addSubview(genderChip)

        let chipsStack = UIStackView(arrangedSubviews: [ageChip, genderChip])
        chipsStack.axis = .horizontal
        chipsStack.spacing = 8
        chipsStack.alignment = .center
        chipsStack.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [nameLabel, chipsStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            avatarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            avatarContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 64),
            avatarContainer.heightAnchor.constraint(equalToConstant: 64),

            avatar.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatar.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            stack.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            ageChip.heightAnchor.constraint(equalToConstant: 24),
            genderChip.heightAnchor.constraint(equalToConstant: 24)
        ])

        // add edit & delete buttons
        let editBtn = UIButton(type: .system)
        editBtn.setTitle("✏️", for: .normal)
        editBtn.translatesAutoresizingMaskIntoConstraints = false
        editBtn.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        contentView.addSubview(editBtn)

        let delBtn = UIButton(type: .system)
        delBtn.setTitle("🗑", for: .normal)
        delBtn.translatesAutoresizingMaskIntoConstraints = false
        delBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        contentView.addSubview(delBtn)

        NSLayoutConstraint.activate([
            delBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            delBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            editBtn.trailingAnchor.constraint(equalTo: delBtn.leadingAnchor, constant: -8),
            editBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func configure(with s: Student) {
        avatar.text = s.avatarEmoji
        // pick a soft pastel color based on the name hash
        avatarContainer.backgroundColor = pastelColor(for: s.name)
        nameLabel.text = s.name
        ageChip.text = "\(s.age) "
        genderChip.text = "\(s.gender) "
    }

    private func pastelColor(for key: String) -> UIColor {
        var total: Int = 0
        for u in key.unicodeScalars { total += Int(UInt32(u)) }
        srand48(total)
        let r = CGFloat(0.6 + drand48() * 0.4)
        let g = CGFloat(0.6 + drand48() * 0.4)
        let b = CGFloat(0.6 + drand48() * 0.4)
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    @objc private func editTapped() { onEdit?() }
    @objc private func deleteTapped() { onDelete?() }
}
