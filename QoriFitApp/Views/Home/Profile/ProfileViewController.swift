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

        edadValueLabel.text =  "25 años" // Ejemplo, o sacarlo de prefs
        estaturaValueLabel.text = "1.75 m"
    }

    // MARK: - Data Fetching
    private func fetchActivityData() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        let group = DispatchGroup()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let rangoSemana = self.getWeekRange(for: Date())

        var caloriesData: [MealSummaryByDate]?
        var stepsData: [StepsByDate]?
        var fetchError: Error?

        // 1. Calorías (Usando el servicio actualizado que devuelve [MealSummaryByDate])
        group.enter()
        caloriesService.getCaloriesSummary(startDate: rangoSemana.start, endDate: rangoSemana.end) { result in
            switch result {
            case .success(let lista):
                caloriesData = lista
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }

        // 2. Pasos (Usando el servicio que ya acepta rangos)
        group.enter()
        // Si quieres solo hoy, endDate puede ser el mismo todayStr o nil
        stepService.getStepSummary(startDate: rangoSemana.start, endDate: rangoSemana.end) { result in
            switch result {
            case .success(let data):
                stepsData = data
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true

            if let error = fetchError {
                print("Error cargando actividad: \(error.localizedDescription)")
            }

            // Actualizamos la UI con lo que hayamos obtenido
            self.updateActivityUI(calories: caloriesData, steps: stepsData)
        }
    }
    
    private func updateActivityUI(calories: [MealSummaryByDate]?, steps: [StepsByDate]?) {
        
    
        let totalPasos = steps?.reduce(0) { $0 + $1.steps } ?? 0
        pasosValueLabel.text = "\(totalPasos)"
        
        // 2. Sumamos todas las calorías de la lista
        let totalCalorias = calories?.reduce(0.0) { $0 + $1.totalCalories } ?? 0.0
        caloriasValueLabel.text = String(format: "%.0f kcal", totalCalorias)
        
        // 3. Cálculo de distancia (asumiendo 0.8 metros por paso)
        let distanciaKm = Double(totalPasos) * 0.0008
        distanciaValueLabel.text = String(format: "%.2f km", distanciaKm)

        // 4. Cálculo de tiempo estimado (1 min cada 100 pasos aprox)
        let totalMinutos = totalPasos / 100
        let horas = totalMinutos / 60
        let minutos = totalMinutos % 60
        
        if horas > 0 {
            tiempoValueLabel.text = "\(horas)h \(minutos)m"
        } else {
            tiempoValueLabel.text = "\(minutos) min"
        }
    }

    // MARK: - Helpers


    @IBAction func btnLogOut(_ sender: UIButton) {
        let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Estás seguro?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Salir", style: .destructive) { _ in
            self.performLogout()
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    func getWeekRange(for date: Date) -> (start: String, end: String) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Obtenemos el intervalo de la semana que contiene a 'date'
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return ("", "")
        }
        
        // El final del intervalo es el primer segundo de la siguiente semana,
        // por eso restamos 1 segundo para tener el sábado/domingo real.
        let startDate = interval.start
        let endDate = calendar.date(byAdding: .second, value: -1, to: interval.end)!
        
        return (formatter.string(from: startDate), formatter.string(from: endDate))
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

