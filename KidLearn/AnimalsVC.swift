import UIKit
import AVFoundation
// Refactored: removed Objective-C associated object usage; titles stored directly.

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

final class AnimalsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let animals: [(emoji: String, name: String, images: [String])] = [
        ("🐶", "Dogs", ["dog_11","dog_22","dog_33"]),
        ("🐱", "Cat", ["cat_11","cat_22","cat_33"]),
        ("🦁", "Lion", ["lion_11","lion_22"]),
        
    ]

    private var carouselCollection: UICollectionView!
    private var carouselPage = UIPageControl()
    private var currentImages: [UIImage] = []
    // Cache decoded images to avoid re-decoding
    private let imageCache = NSCache<NSString, UIImage>()
    private let speak = AVSpeechSynthesizer()

    // Titles derived from animal groups flattened to parallel currentImages.
    private var imageTitles: [String] = []

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

        // Prepare titles and lazily load images on demand
        currentImages.removeAll()
        imageTitles.removeAll()
        for group in animals {
            for imgName in group.images {
                imageTitles.append(group.name)
                let key = NSString(string: imgName)
                if let cached = imageCache.object(forKey: key) {
                    currentImages.append(cached)
                } else if let placeholder = UIHelper.image(from: group.emoji, size: CGSize(width: 800, height: 450)) {
                    currentImages.append(placeholder)
                } else {
                    currentImages.append(UIImage())
                }
            }
        }
        carouselPage.numberOfPages = currentImages.count
        carouselPage.currentPage = 0
        carouselCollection.reloadData()
        if let cap = view.viewWithTag(999) as? UILabel, let firstTitle = imageTitles.first {
            cap.text = firstTitle
        }
    }

    

    // MARK: - Carousel Data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimalImageCell.reuseIdentifier, for: indexPath) as? AnimalImageCell else { return UICollectionViewCell() }
        // determine the animal image name for this index
        var imageName: String?
        var emoji: String = "🐾"
        var countSoFar = 0
        findImage: for a in animals {
            for name in a.images {
                if countSoFar == indexPath.item {
                    imageName = name
                    emoji = a.emoji
                    break findImage
                }
                countSoFar += 1
            }
        }
        if let imageName = imageName {
            let key = NSString(string: imageName)
            if let cached = imageCache.object(forKey: key) {
                cell.imageView.image = cached
            } else if let img = UIImage(named: imageName) {
                imageCache.setObject(img, forKey: key)
                cell.imageView.image = img
            } else {
                cell.imageView.image = UIHelper.image(from: emoji, size: CGSize(width: 800, height: 450))
            }
        } else {
            cell.imageView.image = currentImages[indexPath.item]
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == carouselCollection else { return }
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        carouselPage.currentPage = page
        if page < imageTitles.count, let cap = view.viewWithTag(999) as? UILabel {
            cap.text = imageTitles[page]
        }
    }

    // Helper methods moved to UIHelper for image generation.
}
