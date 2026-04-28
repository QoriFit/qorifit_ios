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
    
    @IBOutlet weak var lblIMC: UILabel!
    
    
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
    
    private func calculateAge(from birthdate: Date?) -> Int {
        guard let date = birthdate else { return 0 }
        
        let now = Date()
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        
        return ageComponents.year ?? 0
    }
    
    private func setupProfileFromPreferences() {
        guard let prefs = CoreDataManager.shared.getPreferences() else { return }
        
        // 1. Datos Básicos
        let name = prefs.username ?? "Sin especificar"
        let email = prefs.email ?? "Sin especificar"
        let weight = prefs.weight // Double
        let height = prefs.height // Int32 (asumiendo cm, ej: 175)
        let edadCalculada = calculateAge(from: prefs.birthdate)
            
        
        usernameLabel.text = "Nombre de usuario: \(name)"
        emailLabel.text = "Correo: \(email)"
        
        // 2. Formateo de valores numéricos
        pesoValueLabel.text = weight > 0 ? "Peso: \(weight) kg" : "Peso: Sin especificar"
        edadValueLabel.text = edadCalculada > 0 ? "Edad: \(edadCalculada) años" : "Edad: Sin especificar"
        
        // Convertimos altura de cm a metros para mostrar (ej: 1.75 m)
        let heightInMeters = Double(height) / 100.0
        estaturaValueLabel.text = height > 0 ? "Estatura: \(heightInMeters) m" : "Estatura: Sin especificar"
        
        // 3. Cálculo y color del IMC
        calculateAndDisplayIMC(weight: weight, heightInMeters: heightInMeters)
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
    
    
    private func calculateAndDisplayIMC(weight: Double, heightInMeters: Double) {
        guard weight > 0, heightInMeters > 0 else {
            lblIMC.text = "IMC: No calculado"
            lblIMC.textColor = .label
            return
        }
        
        let imc = weight / (heightInMeters * heightInMeters)
        let imcString = String(format: "%.1f", imc)
        
        var status = ""
        var color: UIColor = .label
        
        switch imc {
        case ..<18.5:
            status = "Bajo peso"
            color = .systemBlue
        case 18.5..<25:
            status = "Normal"
            color = .systemGreen
        case 25..<30:
            status = "Sobrepeso"
            color = .systemOrange
        default:
            status = "Obesidad"
            color = .systemRed
        }
        
        lblIMC.text = "IMC: \(imcString) (\(status))"
        lblIMC.textColor = color
    }
    
    @IBAction func btnMoreInfoIMC(_ sender: UIButton) {
        let message = """
        El Índice de Masa Corporal (IMC) mide el contenido de grasa corporal en relación a la estatura y el peso.
        
        Rangos:
        • Bajo peso: < 18.5
        • Normal: 18.5 – 24.9
        • Sobrepeso: 25.0 – 29.9
        • Obesidad: > 30.0
        
        Nota: Este valor es referencial y no sustituye una evaluación médica profesional.
        """
        
        let alert = UIAlertController(title: "Sobre el IMC", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func btnEditInfo(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Próximamente",
            message: "Estamos trabajando en esta función. ¡Estará disponible en las próximas actualizaciones de QoriFit! ",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "¡Genial!", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}
