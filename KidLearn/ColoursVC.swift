import UIKit
import AVFoundation

final class ColourCell: UICollectionViewCell {
    static let reuseIdentifier = "ColourCell"
    let swatch = UIView()
    let emojiLabel = UILabel()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear

        swatch.translatesAutoresizingMaskIntoConstraints = false
        swatch.layer.cornerRadius = 10
        swatch.layer.shadowColor = UIColor.black.cgColor
        swatch.layer.shadowOpacity = 0.08
        swatch.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(swatch)

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = UIFont.systemFont(ofSize: 36)
        emojiLabel.textAlignment = .center
        swatch.addSubview(emojiLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            swatch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            swatch.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            swatch.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            swatch.heightAnchor.constraint(equalTo: swatch.widthAnchor, multiplier: 0.6),

            emojiLabel.centerXAnchor.constraint(equalTo: swatch.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: swatch.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: swatch.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        swatch.backgroundColor = .clear
        emojiLabel.text = nil
        nameLabel.text = nil
        accessibilityLabel = nil
    }
}

final class ColoursViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private var collectionView: UICollectionView!
    private let speech = AVSpeechSynthesizer()

    private let colours: [(name: String, color: UIColor, emoji: String?)] = [
        ("Red", UIColor.systemRed, "🍎"),
        ("Orange", UIColor.systemOrange, "🍊"),
        ("Yellow", UIColor.systemYellow, "🍋"),
        ("Green", UIColor.systemGreen, "🍏"),
        ("Teal", UIColor.systemTeal, "🐬"),
        ("Blue", UIColor.systemBlue, "🧢"),
        ("Purple", UIColor.systemPurple, "🍇"),
        ("Pink", UIColor.systemPink, "🍥"),
        ("Brown", UIColor.brown, "🥐"),
        ("Gray", UIColor.systemGray, "🐘"),
        ("Black", UIColor.black, "⚫️"),
        ("White", UIColor.white, "⚪️")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "Colours"
        setupCollection()
    }

    private func setupCollection() {
        // responsive compositional layout
        let layout = UICollectionViewCompositionalLayout { sectionIndex, env -> NSCollectionLayoutSection? in
            let width = env.container.effectiveContentSize.width
            let columns: CGFloat = width > 700 ? 4 : 3
            let spacing: CGFloat = 12

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/columns), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: spacing/2, leading: spacing/2, bottom: spacing/2, trailing: spacing/2)

            let groupHeight = NSCollectionLayoutDimension.absolute((width / columns) * 0.85)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(columns))

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(ColourCell.self, forCellWithReuseIdentifier: ColourCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Collection Data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colours.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColourCell.reuseIdentifier, for: indexPath) as? ColourCell else {
            return UICollectionViewCell()
        }
        let item = colours[indexPath.item]
    cell.swatch.backgroundColor = item.color
    cell.nameLabel.text = item.name
    cell.nameLabel.textColor = UIColor.label
    cell.emojiLabel.text = item.emoji ?? ""
    cell.emojiLabel.textColor = textColor(for: item.color)
    cell.emojiLabel.layer.shadowColor = UIColor.black.cgColor
    cell.emojiLabel.layer.shadowOpacity = 0.12
    cell.emojiLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
    cell.isAccessibilityElement = true
    cell.accessibilityLabel = accessibilityDescription(for: item.color, name: item.name)
    return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.12, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [], animations: {
                cell.transform = .identity
            }, completion: nil)
        })

    // Speak color name using TalkingTomManager
    let name = colours[indexPath.item].name
    TalkingTomManager.shared.speak(text: name)
    }

    private func textColor(for color: UIColor) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = (0.299 * r + 0.587 * g + 0.114 * b)
        return lum > 0.6 ? UIColor.black : UIColor.white
    }
    private func accessibilityDescription(for color: UIColor, name: String) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let toPct = { (v: CGFloat) -> Int in Int(round(v * 100)) }
        return "\(name) colour. Approx RGB: R \(toPct(r))%, G \(toPct(g))%, B \(toPct(b))%."
    }
}
