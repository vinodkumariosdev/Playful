import UIKit

class FruitsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupUI()
    }

    private func setupUI() {
        title = "Fruits & Veg"
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fruits & Veggies"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])

        let items = [("🍎","Apple"),("🍌","Banana"),("🥕","Carrot"),("🍇","Grapes"),("🍓","Strawberry"),("🥦","Broccoli")]
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        for (emoji, name) in items {
            let h = UIStackView()
            h.axis = .horizontal
            h.spacing = 12
            h.alignment = .center
            h.distribution = .fill
            h.translatesAutoresizingMaskIntoConstraints = false
            let em = UILabel()
            em.font = UIFont.systemFont(ofSize: 36)
            em.text = emoji
            em.setContentHuggingPriority(.required, for: .horizontal)
            let nameL = UILabel()
            nameL.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            nameL.text = name
            h.addArrangedSubview(em)
            h.addArrangedSubview(nameL)
            h.backgroundColor = UIColor.secondarySystemBackground
            h.layer.cornerRadius = 10
            h.isLayoutMarginsRelativeArrangement = true
            h.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            stack.addArrangedSubview(h)
        }
    }
}
