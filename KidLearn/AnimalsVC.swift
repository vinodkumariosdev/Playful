import UIKit
import AVFoundation
import ObjectiveC

final class AnimalImageCell: UICollectionViewCell {
    static let reuseIdentifier = "AnimalImageCell"
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AnimalsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let animals: [(emoji: String, name: String, images: [String])] = [
        ("🐶", "Dogs", ["dog_11","dog_22","dog_33"]),
        ("🐱", "Cat", ["cat_11","cat_22","cat_33"]),
        ("🦁", "Lion", ["lion_11","lion_22"]),
        
    ]

    private var carouselCollection: UICollectionView!
    private var carouselPage = UIPageControl()
    private var currentImages: [UIImage] = []
    // titles parallel to currentImages
    private var currentTitles: [String] = []
    private let speak = AVSpeechSynthesizer()

    private struct AssociatedKeys {
        static var carouselTitles = "carouselTitles"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupUI()
    }

    private func setupUI() {
        title = "Animals"
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Animals"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // carousel (full-width slides)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        carouselCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        carouselCollection.translatesAutoresizingMaskIntoConstraints = false
        carouselCollection.register(AnimalImageCell.self, forCellWithReuseIdentifier: AnimalImageCell.reuseIdentifier)
        carouselCollection.dataSource = self
        carouselCollection.delegate = self
        carouselCollection.isPagingEnabled = true
        carouselCollection.showsHorizontalScrollIndicator = false
        carouselCollection.backgroundColor = .clear
        view.addSubview(carouselCollection)

        // caption label below slide
        let caption = UILabel()
        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        caption.textAlignment = .center
        caption.tag = 999 // store as subview by tag for updates
        view.addSubview(caption)

        carouselPage.translatesAutoresizingMaskIntoConstraints = false
        carouselPage.currentPage = 0
        view.addSubview(carouselPage)

        NSLayoutConstraint.activate([
            carouselCollection.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12),
            carouselCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carouselCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carouselCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),

            carouselPage.topAnchor.constraint(equalTo: carouselCollection.bottomAnchor, constant: 8),
            carouselPage.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            caption.topAnchor.constraint(equalTo: carouselPage.bottomAnchor, constant: 8),
            caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // load all PNG images listed for each animal into the carousel
        currentImages = []
        var titles: [String] = []
        for a in animals {
            for name in a.images {
                if let img = UIImage(named: name) {
                    currentImages.append(img)
                    titles.append(a.name)
                } else if let placeholder = image(from: a.emoji, size: CGSize(width: 800, height: 450)) {
                    currentImages.append(placeholder)
                    titles.append(a.name)
                }
            }
        }
        if currentImages.isEmpty {
            // fallback: generate one placeholder per animal
            for a in animals {
                if let img = image(from: a.emoji, size: CGSize(width: 800, height: 450)) {
                    currentImages.append(img)
                    titles.append(a.name)
                }
            }
        }
        // store titles in carouselPage's accessibilityValue for simple access
        carouselPage.numberOfPages = currentImages.count
        carouselPage.currentPage = 0
        carouselCollection.reloadData()
        // set initial caption
        if let cap = view.viewWithTag(999) as? UILabel, titles.count > 0 {
            cap.text = titles[0]
        }
        // keep titles array in an associated property via objc_setAssociatedObject
        objc_setAssociatedObject(self, &AssociatedKeys.carouselTitles, titles, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    

    // MARK: - Carousel Data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimalImageCell.reuseIdentifier, for: indexPath) as? AnimalImageCell else { return UICollectionViewCell() }
        cell.imageView.image = currentImages[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == carouselCollection {
            let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            carouselPage.currentPage = page
            // update caption from stored titles
            if let titles = objc_getAssociatedObject(self, &AssociatedKeys.carouselTitles) as? [String], page < titles.count {
                if let cap = view.viewWithTag(999) as? UILabel { cap.text = titles[page] }
            }
        }
    }

    private func image(from emoji: String, size: CGSize) -> UIImage? {
        let label = UILabel(frame: CGRect(origin: .zero, size: size))
        label.text = emoji
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: min(size.width, size.height) * 0.6)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
