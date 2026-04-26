import UIKit

class RecipeDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var recipeId: Int = 0
    private var recipeDetail: RecipeDetail?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detalle"
        setupUI()
        loadDetail()
    }

    private func setupUI() {
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = recipeImageView.frame.width / 2

        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Detalles", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Instrucciones", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0

        contentTextView.isEditable = false
        contentTextView.font = .systemFont(ofSize: 15)
        contentTextView.textAlignment = .center

        activityIndicator.hidesWhenStopped = true
    }

    // MARK: - IBActions

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateContent()
    }

    // MARK: - Data

    private func loadDetail() {
        activityIndicator.startAnimating()

        ComidaService.shared.fetchRecipeDetail(id: recipeId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let detail):
                    self?.recipeDetail = detail
                    self?.displayDetail(detail)
                case .failure(let error):
                    self?.contentTextView.text = "Error al cargar: \(error.localizedDescription)"
                }
            }
        }
    }

    private func displayDetail(_ detail: RecipeDetail) {
        recipeNameLabel.text = detail.name

        // Cargar imagen si existe
        if let urlString = detail.imagePath, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.recipeImageView.image = image
                    }
                }
            }.resume()
        } else {
            recipeImageView.image = UIImage(systemName: "fork.knife.circle.fill")
            recipeImageView.tintColor = .systemGray3
        }

        updateContent()
    }

    private func updateContent() {
        guard let detail = recipeDetail else { return }

        if segmentedControl.selectedSegmentIndex == 0 {
            // DETALLES
            var lines: [String] = []
            lines.append("")
            lines.append("País de origen")
            lines.append(detail.countryName ?? "No disponible")
            lines.append("")
            lines.append("Calorías estimadas")
            if let cal = detail.estimatedCalories {
                lines.append("\(cal) kcal")
            } else if let cal = detail.totalCalories {
                lines.append("\(cal) kcal")
            } else {
                lines.append("No disponible")
            }
            lines.append("")
            lines.append("Popularidad")
            if let pop = detail.popularity {
                lines.append("\(pop) / 100")
            } else {
                lines.append("No disponible")
            }
            lines.append("")
            lines.append("Descripción")
            lines.append(detail.description ?? "Sin descripción")
            lines.append("")

            contentTextView.textAlignment = .center
            contentTextView.text = lines.joined(separator: "\n")

        } else {
            // INSTRUCCIONES
            contentTextView.textAlignment = .left

            if let instructions = detail.instructions, !instructions.isEmpty {
                contentTextView.text = "INSTRUCCIONES\n\n\(instructions)"
            } else {
                contentTextView.text = "Instrucciones no disponibles por el momento."
            }
        }
    }
}
