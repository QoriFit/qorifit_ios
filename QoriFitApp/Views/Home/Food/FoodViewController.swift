import UIKit

class FoodViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var foodCollectionView: UICollectionView!

    // MARK: Properties
    private var foods: [FoodItem] = []
    private let db = CoreDataManager.shared

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFoods()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }

    // MARK: Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.937, green: 0.902, blue: 0.843, alpha: 1)
        title = "Recomendaciones"
        navigationController?.navigationBar.tintColor = UIColor(red: 0.35, green: 0.22, blue: 0.1, alpha: 1)
    }

    private func setupCollectionView() {
        foodCollectionView.backgroundColor = .clear
        foodCollectionView.dataSource = self
        foodCollectionView.delegate   = self
        foodCollectionView.register(FoodCell.self, forCellWithReuseIdentifier: FoodCell.identifier)
    }

    private func updateLayout() {
        let spacing: CGFloat = 12
        let padding: CGFloat = 16
        let totalWidth = foodCollectionView.bounds.width - (padding * 2) - spacing
        let layout = UICollectionViewFlowLayout()
        layout.itemSize                = CGSize(width: totalWidth / 2, height: 220)
        layout.minimumLineSpacing      = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset            = UIEdgeInsets(top: 16, left: padding, bottom: 16, right: padding)
        foodCollectionView.collectionViewLayout = layout
    }

    // MARK: CoreData
    private func loadFoods() {
        foods = db.fetchAllFoods()
        foodCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension FoodViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foods.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoodCell.identifier, for: indexPath) as! FoodCell
        cell.configure(with: foods[indexPath.item])
        cell.onFavoriteTapped = { [weak self] in
            guard let self else { return }
            let food = self.foods[indexPath.item]
            self.db.toggleFavorite(foodId: food.id)
            self.foods[indexPath.item].isFavorite.toggle()
            collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FoodViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = FoodDetailViewController()
        vc.food = foods[indexPath.item]
        vc.onFavoriteChanged = { [weak self] isFavorite in
            guard let self else { return }
            self.db.toggleFavorite(foodId: self.foods[indexPath.item].id)
            self.foods[indexPath.item].isFavorite = isFavorite
            collectionView.reloadItems(at: [indexPath])
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
