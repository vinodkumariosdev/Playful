import UIKit
import AVFoundation

final class NumberCardCell: UICollectionViewCell {
    static let reuseIdentifier = "NumberCardCell"
    let circleView = UIView()
    let numberLabel = UILabel()
    let nameLabel = UILabel()
     let badgeLabel = UILabel()
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear

        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 14
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOpacity = 0.12
        circleView.layer.shadowOffset = CGSize(width: 0, height: 6)
        circleView.layer.masksToBounds = false
        // gradient background
        gradient.startPoint = CGPoint(x: 0.1, y: 0)
        gradient.endPoint = CGPoint(x: 0.9, y: 1)
        circleView.layer.insertSublayer(gradient, at: 0)
        contentView.addSubview(circleView)

        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.font = UIFont.systemFont(ofSize: 120, weight: .heavy)
        numberLabel.textAlignment = .center
        numberLabel.textColor = .white
        circleView.addSubview(numberLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor(white: 0.12, alpha: 1)
        contentView.addSubview(nameLabel)

        // small badge (emoji or sparkle) top-right
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.font = UIFont.systemFont(ofSize: 20)
        badgeLabel.textAlignment = .center
        badgeLabel.text = "✨"
        badgeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        circleView.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            circleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.78),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor),

            numberLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
            ,
            badgeLabel.topAnchor.constraint(equalTo: circleView.topAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: -10),
            badgeLabel.widthAnchor.constraint(equalToConstant: 28),
            badgeLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // update gradient frame & corner radius
        gradient.frame = circleView.bounds
        // use a rounded-square appearance instead of perfect circle
        let corner: CGFloat = 14
        circleView.layer.cornerRadius = corner
        gradient.cornerRadius = corner
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.layer.masksToBounds = true
        nameLabel.layer.cornerRadius = 10
        nameLabel.layer.masksToBounds = true
    }
}

class NumbersVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private var collectionView: UICollectionView!
    private let numbers = Array(1...10)
    private let itemsPerPage = 10
    private let pageControl = UIPageControl()
    private let speech = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupHeader()
        setupCollection()
        setupPageControl()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // speak first number when screen appears
        speakNumber(at: 0)
        // play little jingle
        // keep entry quiet by default (user asked for silence on main screen)
        // AudioManager.shared.playJingle(named: "numbers_jingle.wav")
    }

    private func setupBackground() {
        let g = CAGradientLayer()
        g.colors = [UIColor(red: 0.98, green: 0.95, blue: 0.88, alpha: 1).cgColor, UIColor(red: 0.99, green: 0.86, blue: 0.9, alpha: 1).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.frame = view.bounds
        view.layer.insertSublayer(g, at: 0)
    }

    private func setupHeader() {
        title = "Numbers"
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Learn Numbers"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.15, green: 0.45, blue: 0.9, alpha: 1)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupCollection() {
        // Use a compositional layout: 2 columns x 2 rows per page, group-paging behavior
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            // item takes half width, half height of group
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.5))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            // a row containing 2 items
            let rowSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
            let row = NSCollectionLayoutGroup.horizontal(layoutSize: rowSize, subitem: item, count: 2)

            // vertical group of two rows (2x2)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [row, row])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NumberCardCell.self, forCellWithReuseIdentifier: NumberCardCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])
    }

    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        let pages = Int(ceil(Double(numbers.count) / Double(itemsPerPage)))
        pageControl.numberOfPages = max(1, pages)
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.5)
        pageControl.currentPageIndicatorTintColor = UIColor.white
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Collection Data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberCardCell.reuseIdentifier, for: indexPath) as? NumberCardCell else {
            return UICollectionViewCell()
        }
        let value = numbers[indexPath.item]
        cell.numberLabel.text = "\(value)"
        // set written name under the number
        let names = ["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten"]
        if value >= 1 && value <= names.count {
            cell.nameLabel.text = names[value - 1]
        } else {
            cell.nameLabel.text = "\(value)"
        }
        // colorful background per number
        let hue = CGFloat((value % 10)) / 10.0
        cell.circleView.backgroundColor = UIColor(hue: hue, saturation: 0.6, brightness: 0.95, alpha: 1)
        cell.circleView.layer.cornerRadius = min(cell.circleView.bounds.width, cell.circleView.bounds.height) / 2

        // selection is handled in collectionView(_:didSelectItemAt:)

        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        pageControl.currentPage = page
        // speak the first number on this page
        let firstIndex = page * itemsPerPage
        speakNumber(at: firstIndex)
        AudioManager.shared.playJingle(named: "numbers_jingle.wav")
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // subtle pop animation
        cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        UIView.animate(withDuration: 0.36, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [], animations: {
            cell.transform = .identity
        }, completion: nil)
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let value = numbers[indexPath.item]
        // try to play a per-number audio file named like "number_1.wav" if present;
        // AudioManager falls back to a synthesized chime if the file is missing
        // visual pulse animation
        if let cell = collectionView.cellForItem(at: indexPath) as? NumberCardCell {
            UIView.animate(withDuration: 0.12, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }, completion: { _ in
                UIView.animate(withDuration: 0.36, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1, options: [], animations: {
                    cell.transform = .identity
                }, completion: nil)
            })
            // sparkle badge flash
            UIView.animate(withDuration: 0.18, animations: {
                cell.badgeLabel.alpha = 0.0
            }, completion: { _ in
                cell.badgeLabel.alpha = 1.0
            })
        }

        // play per-number audio if available (optional), and speak the number
        AudioManager.shared.playJingle(named: "number_\(value).wav")
        speak(text: "\(value)")
    }

    private func speakNumber(at index: Int) {
        guard index >= 0 && index < numbers.count else { return }
        let n = numbers[index]
        speak(text: "\(n)")
    }

    private func speak(text: String) {
        if speech.isSpeaking {
            speech.stopSpeaking(at: .immediate)
        }
        let ut = AVSpeechUtterance(string: text)
        ut.voice = AVSpeechSynthesisVoice(language: "en-US")
        ut.rate = 0.45
        speech.speak(ut)
    }
}

