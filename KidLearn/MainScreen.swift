import UIKit
import AVFoundation

final class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCell"
    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
    contentView.backgroundColor = UIColor(white: 1, alpha: 0.9)
    contentView.layer.cornerRadius = Theme.defaultCornerRadius
    contentView.layer.shadowColor = Theme.cardShadow.cgColor
    contentView.layer.shadowOpacity = 0.08
    contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.masksToBounds = false

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainScreen: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private let name: String
    private var collectionView: UICollectionView!
    private var tomToggle: UISwitch = UISwitch()

    private struct Category {
        let title: String
        let emoji: String
        let assetName: String? // optional image asset name
        let soundFile: String // filename including extension
        let bgColor: UIColor
    }

    private let categories: [Category] = [
        Category(title: "Parent", emoji: "👪", assetName: "parent_icon", soundFile: "", bgColor: Theme.bgParent),
        Category(title: "Numbers", emoji: "🔢", assetName: "numbers_icon", soundFile: "numbers_jingle.wav", bgColor: Theme.bgNumbers),
        Category(title: "Shapes", emoji: "🔺", assetName: "shapes_icon", soundFile: "shapes_jingle.wav", bgColor: Theme.bgShapes),
        Category(title: "Colours", emoji: "🎨", assetName: "colours_icon", soundFile: "colours_jingle.wav", bgColor: Theme.bgColours),
        Category(title: "Animals", emoji: "🦁", assetName: "animals_icon", soundFile: "animals_jingle.wav", bgColor: Theme.bgAnimals),
        Category(title: "Fruits & Vegetables", emoji: "🍎", assetName: "fruits_icon", soundFile: "fruits_jingle.wav", bgColor: Theme.bgFruits),
        Category(title: "Draw", emoji: "✏️", assetName: nil, soundFile: "", bgColor: Theme.bgDraw)
    ]

    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        setupHeader()
        setupCollection()
    }

    private func setupHeader() {
        // Container bar
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = UIColor.secondarySystemBackground
        bar.layer.cornerRadius = 14
        bar.layer.shadowColor = Theme.cardShadow.cgColor
        bar.layer.shadowOpacity = 0.15
        bar.layer.shadowRadius = 6
        bar.layer.shadowOffset = CGSize(width: 0, height: 4)

    let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome, \(name)!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.textColor = Theme.primaryText

        let tomLabel = UILabel()
        tomLabel.translatesAutoresizingMaskIntoConstraints = false
        tomLabel.text = "Talking Tom"
        tomLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        tomLabel.textColor = Theme.primaryText

        tomToggle.translatesAutoresizingMaskIntoConstraints = false
        tomToggle.isOn = TalkingTomManager.shared.isEnabled
        tomToggle.addTarget(self, action: #selector(toggleTom(_:)), for: .valueChanged)

    let settingsButton = UIButton(type: .system)
    settingsButton.translatesAutoresizingMaskIntoConstraints = false
    settingsButton.setTitle("⚙︎", for: .normal)
    settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

    view.addSubview(bar)
        bar.addSubview(label)
        bar.addSubview(tomLabel)
        bar.addSubview(tomToggle)
    bar.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bar.heightAnchor.constraint(equalToConstant: 72),

            label.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: tomLabel.leadingAnchor, constant: -12),

            tomToggle.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            tomToggle.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),

            tomLabel.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            tomLabel.trailingAnchor.constraint(equalTo: tomToggle.leadingAnchor, constant: -8),
            settingsButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            settingsButton.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 12),
            settingsButton.trailingAnchor.constraint(equalTo: tomLabel.leadingAnchor, constant: -12)
        ])
    }

    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 16
        let columns: CGFloat = 2
        let totalPadding = padding * (columns + 1)
        let itemWidth = (view.bounds.width - totalPadding) / columns
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 0.9)
        layout.sectionInset = UIEdgeInsets(top: 16, left: padding, bottom: 16, right: padding)
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 12

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 104),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Collection Data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
    let model = categories[indexPath.item]
        cell.titleLabel.text = model.title
        cell.contentView.backgroundColor = model.bgColor
        // try asset first, otherwise generate a high-quality stylized icon at runtime
        if let asset = model.assetName, let img = UIImage(named: asset) {
            cell.imageView.image = img
        } else {
            cell.imageView.image = UIHelper.makeStylizedIcon(emoji: model.emoji, size: 160, bgColor: model.bgColor)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // playful tap animation + jingle, then placeholder alert
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell else { return }
        animateCellTap(cell)
        // no sound on main screen or on cell tap (user preference)
        let category = categories[indexPath.item]
        guard !category.title.isEmpty else { return }
        // Talking Tom voice for the selected category
        TalkingTomManager.shared.speak(text: category.title)
        // navigate to the corresponding category view controller
        var vcToPush: UIViewController?
        switch category.title {
        case "Parent":
            vcToPush = StudentDetailsVC()
        case "Numbers":
            vcToPush = NumbersVC()
        case "Shapes":
            vcToPush = ShapesVC()
        case "Colours":
            vcToPush = ColoursVC()
        case "Animals":
            vcToPush = AnimalsVC()
        case "Fruits & Vegetables":
            vcToPush = FruitsVC()
        case "Draw":
            vcToPush = DrawingViewController()
        default:
            vcToPush = nil
        }

        if let toPush = vcToPush {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.navigationController?.pushViewController(toPush, animated: true)
            }
        } else {
            // fallback: show simple alert if no VC available
            let title = category.title
            let alert = UIAlertController(title: title, message: "Open \(title) activities (not implemented)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.present(alert, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell {
            UIView.animate(withDuration: 0.12) {
                cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                cell.contentView.alpha = 0.98
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell {
            UIView.animate(withDuration: 0.18, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [], animations: {
                cell.transform = .identity
                cell.contentView.alpha = 1.0
            }, completion: nil)
        }
    }

    private func animateCellTap(_ cell: CategoryCell) {
        UIView.animate(withDuration: 0.12, animations: {
            cell.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        }, completion: { _ in
            UIView.animate(withDuration: 0.36, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.2, options: [], animations: {
                cell.transform = .identity
            }, completion: nil)
        })
    }

    @objc private func toggleTom(_ sender: UISwitch) {
        TalkingTomManager.shared.isEnabled = sender.isOn
        // Provide subtle feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    @objc private func openSettings() {
        let vc = SettingsViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    private func imageFromEmoji(_ emoji: String, size: CGFloat) -> UIImage? {
        let label = UILabel()
        label.text = emoji
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: size)
        let targetSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    // Generate a stylized icon: rounded gradient circle with centered emoji and subtle shadow
    // moved to UIHelper
}
