import UIKit

class FoodDetailViewController: UIViewController {

    // MARK: Properties
    var food: FoodItem?
    var onFavoriteChanged: ((Bool) -> Void)?

    private var isFavorite: Bool = false {
        didSet {
            let title = isFavorite ? "♥" : "♡"
            favoriteButton.setTitle(title, for: .normal)
        }
    }

    // MARK: UI Elements
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode              = .scaleAspectFill
        iv.clipsToBounds            = true
        iv.backgroundColor          = UIColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font          = .systemFont(ofSize: 24, weight: .bold)
        lbl.textColor     = UIColor(red: 0.2, green: 0.12, blue: 0.05, alpha: 1)
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let kcalBadge: UIView = {
        let v = UIView()
        v.backgroundColor      = UIColor(red: 0.35, green: 0.22, blue: 0.1, alpha: 0.12)
        v.layer.cornerRadius   = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let kcalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font      = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = UIColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("♡", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 28)
        btn.tintColor        = .systemRed
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.35, green: 0.22, blue: 0.1, alpha: 0.15)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let descriptionTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text      = "Descripción"
        lbl.font      = .systemFont(ofSize: 17, weight: .semibold)
        lbl.textColor = UIColor(red: 0.2, green: 0.12, blue: 0.05, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font          = .systemFont(ofSize: 15, weight: .regular)
        lbl.textColor     = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let addToMealButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Agregar a mis comidas", for: .normal)
        btn.titleLabel?.font  = .systemFont(ofSize: 17, weight: .bold)
        btn.backgroundColor   = UIColor(red: 0.35, green: 0.22, blue: 0.1, alpha: 1)
        btn.tintColor         = .white
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHierarchy()
        setupConstraints()
        populate()
    }

    // MARK: Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.937, green: 0.902, blue: 0.843, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor(red: 0.35, green: 0.22, blue: 0.1, alpha: 1)

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        addToMealButton.addTarget(self, action: #selector(addToMealTapped), for: .touchUpInside)
    }

    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        kcalBadge.addSubview(kcalLabel)

        contentView.addSubview(heroImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(kcalBadge)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(divider)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(addToMealButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Hero image
            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: 280),

            // Name label
            nameLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60),

            // Favorite button
            favoriteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),

            // kcal badge
            kcalBadge.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            kcalBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            kcalBadge.heightAnchor.constraint(equalToConstant: 28),

            // kcal label inside badge
            kcalLabel.topAnchor.constraint(equalTo: kcalBadge.topAnchor, constant: 4),
            kcalLabel.bottomAnchor.constraint(equalTo: kcalBadge.bottomAnchor, constant: -4),
            kcalLabel.leadingAnchor.constraint(equalTo: kcalBadge.leadingAnchor, constant: 10),
            kcalLabel.trailingAnchor.constraint(equalTo: kcalBadge.trailingAnchor, constant: -10),

            // Divider
            divider.topAnchor.constraint(equalTo: kcalBadge.bottomAnchor, constant: 20),
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 1),

            // Description title
            descriptionTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Description body
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Add to meal button
            addToMealButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            addToMealButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addToMealButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addToMealButton.heightAnchor.constraint(equalToConstant: 52),
            addToMealButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    // MARK: Populate
    private func populate() {
        guard let food = food else { return }

        title        = food.name
        nameLabel.text        = food.name
        kcalLabel.text        = "\(food.kcal) kcal"
        descriptionLabel.text = food.description
        isFavorite            = food.isFavorite

        if let image = UIImage(named: food.imageName) {
            heroImageView.image = image
        }
    }

    // MARK: Actions
    @objc private func favoriteTapped() {
        isFavorite.toggle()
        onFavoriteChanged?(isFavorite)

        // Bounce animation
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = .identity
            }
        }
    }

    @objc private func addToMealTapped() {
        guard let food = food else { return }

        let alert = UIAlertController(
            title: "Agregar a comidas",
            message: "¿A qué comida quieres agregar \(food.name)?",
            preferredStyle: .actionSheet
        )

        ["Desayuno", "Almuerzo", "Cena", "Bocadillo"].forEach { mealType in
            alert.addAction(UIAlertAction(title: mealType, style: .default) { [weak self] _ in
                self?.showConfirmation(meal: mealType, food: food)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    private func showConfirmation(meal: String, food: FoodItem) {
        let alert = UIAlertController(
            title: "¡Agregado!",
            message: "\(food.name) agregado al \(meal) (\(food.kcal) kcal)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

