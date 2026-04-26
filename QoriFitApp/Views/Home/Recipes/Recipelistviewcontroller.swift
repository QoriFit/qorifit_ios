import UIKit

enum RecipeListMode {
    case browse
    case register
}

protocol RecipeListDelegate: AnyObject {
    func didRegisterMeal()
}

class RecipeListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var recipesCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var mode: RecipeListMode = .browse
    weak var delegate: RecipeListDelegate?
    private var recipes: [RecipeListItem] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = mode == .register ? "Registrar Comida" : "Recetas"
        setupCollectionView()
        loadRecipes()
    }

    private func setupCollectionView() {
        recipesCollectionView.delegate = self
        recipesCollectionView.dataSource = self
        recipesCollectionView.register(
            UINib(nibName: "RecipeCell", bundle: nil),
            forCellWithReuseIdentifier: "RecipeCell"
        )
        activityIndicator.hidesWhenStopped = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let totalSpacing = spacing * 3
        let width = (recipesCollectionView.frame.width - totalSpacing) / 2
        layout.itemSize = CGSize(width: width, height: width + 40)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        recipesCollectionView.collectionViewLayout = layout
    }

    private func loadRecipes() {
        activityIndicator.startAnimating()

        ComidaService.shared.fetchRecipes { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let recipes):
                    self?.recipes = recipes
                    self?.recipesCollectionView.reloadData()
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UICollectionView

extension RecipeListViewController: UICollectionViewDataSource, UICollectionViewDelegate {

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

        if mode == .register {
            showMealTypeAlert(for: recipe)
        } else {
            let storyboard = UIStoryboard(name: "Recipes", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailViewController") as? RecipeDetailViewController {
                detailVC.recipeId = recipe.recipeId
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }

    private func showMealTypeAlert(for recipe: RecipeListItem) {
        let alert = UIAlertController(title: "Registrar \(recipe.name)",
                                      message: "Selecciona el tipo de comida",
                                      preferredStyle: .actionSheet)

        let mealTypes = [
            ("Desayuno", "BREAKFAST"),
            ("Almuerzo", "LUNCH"),
            ("Cena", "DINNER"),
            ("Bocadillo", "SNACK")
        ]

        for (title, type) in mealTypes {
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.registerMeal(recipe: recipe, mealType: type)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    private func registerMeal(recipe: RecipeListItem, mealType: String) {
        ComidaService.shared.registerMeal(recipeId: recipe.recipeId, mealName: recipe.name, mealType: mealType) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let ok = UIAlertController(title: "Listo",
                                               message: "\(recipe.name) registrado correctamente.",
                                               preferredStyle: .alert)
                    ok.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self?.delegate?.didRegisterMeal()
                        self?.navigationController?.popViewController(animated: true)
                    })
                    self?.present(ok, animated: true)
                case .failure(let error):
                    let err = UIAlertController(title: "Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
                    err.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(err, animated: true)
                }
            }
        }
    }
}
