import UIKit

class RecipeCell: UICollectionViewCell {

    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 8
    }

    func configure(with recipe: RecipeListItem) {
        recipeNameLabel.text = recipe.name

        if let cal = recipe.estimatedCalories {
            caloriesLabel.text = "\(cal) kcal"
        } else {
            caloriesLabel.text = "-- kcal"
        }

        if let urlString = recipe.imagePath, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.recipeImageView.image = image
                    }
                }
            }.resume()
        } else {
            recipeImageView.image = UIImage(systemName: "fork.knife")
            recipeImageView.tintColor = .systemGray3
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        recipeImageView.image = nil
        recipeNameLabel.text = nil
        caloriesLabel.text = nil
    }
}
