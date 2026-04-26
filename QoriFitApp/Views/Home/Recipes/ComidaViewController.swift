import UIKit

class ComidaViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var caloriesCircleView: UIView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var caloriesSubtitleLabel: UILabel!
    @IBOutlet weak var registerCaloriesButton: UIButton!
    @IBOutlet weak var recommendationsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!

    // MARK: - State
    private var recipes: [RecipeListItem] = []
    private var totalCalories: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comida"
        setupUI()
        setupCollectionView()
        loadData()
    }

    // MARK: - Setup

    private func setupUI() {
        caloriesCircleView.layer.cornerRadius = caloriesCircleView.frame.width / 2
        caloriesCircleView.clipsToBounds = true
        caloriesCircleView.backgroundColor = .systemGray6

        caloriesLabel.text = "0"
        caloriesSubtitleLabel.text = "kcal"

        errorLabel.isHidden = true
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 13)

        activityIndicator.hidesWhenStopped = true
    }

    private func setupCollectionView() {
        recommendationsCollectionView.delegate = self
        recommendationsCollectionView.dataSource = self
        recommendationsCollectionView.register(
            UINib(nibName: "RecipeCell", bundle: nil),
            forCellWithReuseIdentifier: "RecipeCell"
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let totalSpacing = spacing * 3
        let width = (recommendationsCollectionView.frame.width - totalSpacing) / 2
        layout.itemSize = CGSize(width: width, height: width + 40)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        recommendationsCollectionView.collectionViewLayout = layout
    }

    // MARK: - IBActions

    @IBAction func registerCaloriesTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Recipes", bundle: nil)
        if let recipesVC = storyboard.instantiateViewController(withIdentifier: "RecipeListViewController") as? RecipeListViewController {
            recipesVC.mode = .register
            recipesVC.delegate = self
            navigationController?.pushViewController(recipesVC, animated: true)
        }
    }

    // MARK: - Data loading

    private func loadData() {
        activityIndicator.startAnimating()
        errorLabel.isHidden = true

        let group = DispatchGroup()

        group.enter()
        ComidaService.shared.fetchCaloriesSummary(date: ComidaService.todayISO()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let summary):
                    self?.totalCalories = summary.totalCalories
                    self?.caloriesLabel.text = "\(summary.totalCalories)"
                case .failure(let error):
                    print("⚠️ Calories error: \(error.localizedDescription)")
                    self?.caloriesLabel.text = "0"
                }
                group.leave()
            }
        }

        group.enter()
        ComidaService.shared.fetchRecipes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recipes):
                    self?.recipes = recipes
                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.recommendationsCollectionView.reloadData()
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}

// MARK: - UICollectionView

extension ComidaViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        cell.configure(with: recipes[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipe = recipes[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailViewController") as? RecipeDetailViewController {
            detailVC.recipeId = recipe.recipeId
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - RecipeListDelegate

extension ComidaViewController: RecipeListDelegate {
    func didRegisterMeal() {
        loadData()
    }
}
