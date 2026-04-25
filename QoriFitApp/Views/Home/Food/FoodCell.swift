import UIKit

class FoodCell: UICollectionViewCell {

    static let identifier = "FoodCell"

    // MARK: Callback
    var onFavoriteTapped: (() -> Void)?

    // MARK: UI Elements
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode              = .scaleAspectFill
        iv.clipsToBounds            = true
        iv.layer.cornerRadius       = 12
        iv.backgroundColor          = UIColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font                    = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor               = UIColor(red: 0.2, green: 0.12, blue: 0.05, alpha: 1)
        lbl.numberOfLines           = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let kcalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font                    = .systemFont(ofSize: 11, weight: .regular)
        lbl.textColor               = UIColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("♡", for: .normal)
        btn.setTitle("♥", for: .selected)
        btn.tintColor               = .systemRed
        btn.titleLabel?.font        = .systemFont(ofSize: 20)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    // MARK: Setup
    private func setupCell() {
        contentView.backgroundColor     = .white
        contentView.layer.cornerRadius  = 16
        contentView.layer.shadowColor   = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset  = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius  = 6
        contentView.clipsToBounds       = false

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(kcalLabel)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            // Image — top 3/5 of cell
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),

            // Name label
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            // kcal label
            kcalLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            kcalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),

            // Favorite button — bottom right
            favoriteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }

    // MARK: Configure
    func configure(with food: FoodItem) {
        nameLabel.text          = food.name
        kcalLabel.text          = "\(food.kcal) kcal"
        favoriteButton.isSelected = food.isFavorite

        // Use asset image if exists, otherwise show placeholder color
        if let image = UIImage(named: food.imageName) {
            imageView.image = image
        } else {
            imageView.image = nil
            imageView.backgroundColor = UIColor(
                red:   CGFloat.random(in: 0.7...0.9),
                green: CGFloat.random(in: 0.6...0.8),
                blue:  CGFloat.random(in: 0.4...0.6),
                alpha: 1
            )
        }
    }

    // MARK: Actions
    @objc private func favoriteTapped() {
        favoriteButton.isSelected.toggle()
        onFavoriteTapped?()
    }

    // MARK: Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image           = nil
        nameLabel.text            = nil
        kcalLabel.text            = nil
        favoriteButton.isSelected = false
        onFavoriteTapped          = nil
    }
}
