import UIKit

final class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCell"
    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
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

    private struct Category {
        let title: String
        let emoji: String
        let assetName: String? // optional image asset name
        let soundFile: String // filename including extension
        let bgColor: UIColor
    }

    private let categories: [Category] = [
        Category(title: "Parent", emoji: "👪", assetName: "parent_icon", soundFile: "", bgColor: UIColor(red:0.76, green:0.92, blue:0.98, alpha:1)),
        Category(title: "Numbers", emoji: "🔢", assetName: "numbers_icon", soundFile: "numbers_jingle.wav", bgColor: UIColor(red:0.98, green:0.92, blue:0.5, alpha:1)),
        Category(title: "Shapes", emoji: "🔺", assetName: "shapes_icon", soundFile: "shapes_jingle.wav", bgColor: UIColor(red:0.9, green:0.78, blue:0.98, alpha:1)),
        Category(title: "Colours", emoji: "🎨", assetName: "colours_icon", soundFile: "colours_jingle.wav", bgColor: UIColor(red:0.9, green:0.96, blue:0.98, alpha:1)),
        Category(title: "Animals", emoji: "🦁", assetName: "animals_icon", soundFile: "animals_jingle.wav", bgColor: UIColor(red:0.98, green:0.86, blue:0.78, alpha:1)),
        Category(title: "Fruits & Vegetables", emoji: "🍎", assetName: "fruits_icon", soundFile: "fruits_jingle.wav", bgColor: UIColor(red:0.85, green:0.98, blue:0.86, alpha:1))
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
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome, \(name)!"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.14, green: 0.46, blue: 0.9, alpha: 1)

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
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
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 72),
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
            cell.imageView.image = makeStylizedIcon(emoji: model.emoji, size: 160, bgColor: model.bgColor)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // playful tap animation + jingle, then placeholder alert
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell else { return }
        animateCellTap(cell)
        // no sound on main screen or on cell tap (user preference)

        // navigate to the corresponding category view controller
        let category = categories[indexPath.item]
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
        default:
            vcToPush = nil
        }

        if let toPush = vcToPush {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.navigationController?.pushViewController(toPush, animated: true)
            }
        } else {
            // fallback: show simple alert if no VC available
            let title = category.title
            let alert = UIAlertController(title: title, message: "Open \(title) activities (not implemented)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.present(alert, animated: true)
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
    private func makeStylizedIcon(emoji: String, size: CGFloat, bgColor: UIColor) -> UIImage? {
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        // draw gradient circle background
        let rect = CGRect(origin: .zero, size: imageSize)
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: 2, dy: 2))
        ctx.saveGState()
        path.addClip()
        let start = bgColor.withAlphaComponent(1.0).cgColor
        let end = bgColor.withAlphaComponent(0.85).withAlphaComponent(0.95).cgColor
        let colors = [start, end] as CFArray
        if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0,1]) {
            ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: imageSize.height), options: [])
        }
        ctx.restoreGState()

        // drop shadow (soft)
        ctx.setShadow(offset: CGSize(width: 0, height: 6), blur: 8, color: UIColor(white: 0, alpha: 0.12).cgColor)

        // draw inner circle highlight
        let innerRect = rect.insetBy(dx: size * 0.08, dy: size * 0.08)
        let innerPath = UIBezierPath(ovalIn: innerRect)
        UIColor.white.withAlphaComponent(0.06).setFill()
        innerPath.fill()

        // draw emoji centered
        let emojiFont = UIFont.systemFont(ofSize: size * 0.55)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [ .font: emojiFont ]
        let attrStr = NSAttributedString(string: emoji, attributes: attrs)
        let textSize = attrStr.size()
        let textRect = CGRect(x: (imageSize.width - textSize.width)/2, y: (imageSize.height - textSize.height)/2, width: textSize.width, height: textSize.height)
        attrStr.draw(in: textRect)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
