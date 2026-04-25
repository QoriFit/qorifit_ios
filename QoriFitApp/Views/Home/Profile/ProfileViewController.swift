import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Services
    private let caloriesService = CaloriesService()
    private let stepService = StepService()
    private let authService = AuthService()
    
    // MARK: - Outlets (Datos Personales)
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var pesoValueLabel: UILabel!
    @IBOutlet weak var edadValueLabel: UILabel!
    @IBOutlet weak var estaturaValueLabel: UILabel!
    @IBOutlet weak var objetivoValueLabel: UILabel!
    
    // MARK: - Outlets (Actividad)
    @IBOutlet weak var pasosValueLabel: UILabel!
    @IBOutlet weak var caloriasValueLabel: UILabel!
    @IBOutlet weak var distanciaValueLabel: UILabel!
    @IBOutlet weak var tiempoValueLabel: UILabel!
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 1. Cargamos lo que está en memoria local (rápido)
        setupProfileFromPreferences()
        // 2. Cargamos lo que viene de internet
        fetchActivityData()
    }

    // MARK: - UI Setup
    private func setupLoader() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }

    private func setupProfileFromPreferences() {
        guard let prefs = CoreDataManager.shared.getPreferences() else { return }
        
        // Asumiendo los nombres de tus campos en Core Data
        usernameLabel.text = prefs.username ?? "Usuario"
        emailLabel.text = UserDefaults.standard.string(forKey: "user_email") ?? "Sin email"
        
        // Aquí puedes formatear los valores numéricos
        pesoValueLabel.text = prefs.unitWeight
        
        // Estos campos dependen de si los guardaste en Core Data
        edadValueLabel.text = "25 años" // Ejemplo, o sacarlo de prefs
        estaturaValueLabel.text = "1.75 m"
    }

    // MARK: - Data Fetching
    private func fetchActivityData() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        let today = getTodayDate()
        let group = DispatchGroup()

        var caloriesData: CaloriesSummary?
        var stepsData: StepsByDate?
        var fetchError: Error?

        // 1. Calorías
        group.enter()
        caloriesService.getCaloriesSummary(date: today) { result in
            // Usamos el switch para ser consistentes con el estándar
            switch result {
            case .success(let data): caloriesData = data
            case .failure(let error): fetchError = error
            }
            group.leave()
        }

        // 2. Pasos
        group.enter()
        stepService.getStepSummary(startDate: today, endDate: today) { result in
            switch result {
            case .success(let data): stepsData = data.first
            case .failure(let error): fetchError = error
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true

            if let error = fetchError {
                print("Error cargando actividad: \(error.localizedDescription)")
                // No mostramos alerta aquí para no molestar al usuario si solo falló la red
            }

            self.updateActivityUI(calories: caloriesData, steps: stepsData)
        }
    }

    private func updateActivityUI(calories: CaloriesSummary?, steps: StepsByDate?) {
        // Usamos los nombres de propiedades que definimos en tus servicios
        pasosValueLabel.text = "\(steps?.steps ?? 0)"
        caloriasValueLabel.text = "\(calories?.calorias ?? 0) kcal"
        distanciaValueLabel.text = String(format: "%.2f km", calories?.distancia ?? 0)

        let tiempo = calories?.tiempo ?? 0
        tiempoValueLabel.text = "\(tiempo / 60)h \(tiempo % 60)m"
    }

    // MARK: - Helpers
    private func getTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    // MARK: - Actions
    @IBAction func btnLogOut(_ sender: UIButton) {
        let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Estás seguro?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Salir", style: .destructive) { _ in
            self.performLogout()
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    func performLogout() {
        
        UserDefaults.standard.removeObject(forKey: "user_jwt")
        UserDefaults.standard.removeObject(forKey: "user_name")

        CoreDataManager.shared.deleteAllPreferences()
        
        // 3. Redirigimos al Login (Main.storyboard)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            window.rootViewController = loginVC
            
            // Animación suave de transición para el cierre de sesión
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}

