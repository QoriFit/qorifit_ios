import UIKit

class StepViewController: UIViewController {

    // MARK: - IBOutlets (conectar desde Storyboard)
    @IBOutlet weak var periodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var stepsCircleView: UIView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var stepsSubtitleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var caloriesValueLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let stepService = StepService()

    // MARK: - State
    private var currentPeriod: StepPeriod = .week
    private var totalSteps: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pasos"
        setupUI()
        loadSteps()
    }

    // MARK: - Setup

    private func setupUI() {
        stepsCircleView.layer.cornerRadius = stepsCircleView.frame.width / 2
        stepsCircleView.clipsToBounds = true

        errorLabel.isHidden = true
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 13)

        activityIndicator.hidesWhenStopped = true

        distanceValueLabel.text = "--"
        caloriesValueLabel.text = "--"
        timeValueLabel.text = "--"
    }

    // MARK: - IBActions

    @IBAction func periodChanged(_ sender: UISegmentedControl) {
        guard let period = StepPeriod(rawValue: sender.selectedSegmentIndex) else { return }
        currentPeriod = period
        loadSteps()
    }

    @IBAction func registerButtonTapped(_ sender: UIButton) {
        showRegisterAlert()
    }

    // MARK: - API calls

    private func loadSteps() {
            errorLabel.isHidden = true
            activityIndicator.startAnimating()
            stepsLabel.text = ""

            let range = self.dateRange(for: currentPeriod)

            // Verifica que esta llamada cierre su paréntesis correctamente al final
            stepService.getStepSummary(startDate: range.0, endDate: range.1) { [weak self] result in
                
                // 1. Desempaquetamos self
                guard let strongSelf = self else { return }
                
                // 2. Ejecutamos en el hilo principal
                DispatchQueue.main.async {
                    strongSelf.activityIndicator.stopAnimating()
                    
                    switch result {
                    case .success(let entries):
                        strongSelf.updateUI(with: entries)
                    case .failure(let error):
                        strongSelf.showError(error.localizedDescription)
                    }
                }
            } // <-- Aquí cierra el getStepSummary
        }

    private func updateUI(with entries: [StepsByDate]) {
        totalSteps = entries.reduce(0) { $0 + $1.steps }
        let distance = Double(totalSteps) * 0.0008
        let calories = Double(totalSteps) * 0.04
        let minutes = totalSteps / 100

        stepsLabel.text = "\(totalSteps)"
        stepsSubtitleLabel.text = "steps"
        distanceValueLabel.text = String(format: "%.2f km", distance)
        caloriesValueLabel.text = String(format: "%.0f kcal", calories)
        timeValueLabel.text = "\(minutes) min"
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        stepsLabel.text = "0"
        distanceValueLabel.text = "--"
        caloriesValueLabel.text = "--"
        timeValueLabel.text = "--"
    }

    // MARK: - Register steps alert

    private func showRegisterAlert() {
        let alert = UIAlertController(title: "Registrar pasos",
                                      message: "Ingresa los pasos y la fecha",
                                      preferredStyle: .alert)

        alert.addTextField { tf in
            tf.placeholder = "Número de pasos"
            tf.keyboardType = .numberPad
        }
        alert.addTextField { tf in
            tf.placeholder = "Fecha (yyyy-MM-dd)"
            tf.text = self.isoDate(Date())
        }

        let saveAction = UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            guard let stepsText = alert.textFields?[0].text,
                  let stepCount = Int(stepsText),
                  let date = alert.textFields?[1].text,
                  !date.isEmpty else {
                self?.showError("Datos inválidos.")
                return
            }
            self?.submitSteps(date: date, stepCount: stepCount)
        }

        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    private func submitSteps(date: String, stepCount: Int) {
        activityIndicator.startAnimating()
        errorLabel.isHidden = true


        stepService.registerSteps(date: date, stepCount: stepCount) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success:
                    let ok = UIAlertController(title: "Listo",
                                               message: "Pasos registrados correctamente.",
                                               preferredStyle: .alert)
                    ok.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ok, animated: true)
                    self?.loadSteps()
                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    func dateRange(for period: StepPeriod) -> (String, String) {
        let cal = Calendar.current
        let today = Date()
        switch period {
        case .day:
            let d = isoDate(today)
            return (d, d)
        case .week:
            let start = cal.date(byAdding: .day, value: -6, to: today)!
            return (isoDate(start), isoDate(today))
        case .month:
            let start = cal.date(byAdding: .day, value: -29, to: today)!
            return (isoDate(start), isoDate(today))
        }
    }
    
    func isoDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    enum StepPeriod: Int, CaseIterable {
        case day = 0
        case week = 1
        case month = 2

        var title: String {
            switch self {
            case .day: return "Day"
            case .week: return "Week"
            case .month: return "Month"
            }
        }
    }
    
    @IBAction func btnStepDetails(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "StepDetails", bundle: nil)
        
        if let stepDetailsVC = storyboard.instantiateViewController(withIdentifier: "StepsDetailsViewController") as? StepsDetailsViewController {
            
            stepDetailsVC.modalPresentationStyle = .fullScreen
            stepDetailsVC.modalTransitionStyle = .crossDissolve

            self.present(stepDetailsVC, animated: true, completion: nil)
        } else {
            print("Error: No se pudo instanciar StepsDetailsViewController. Revisa el Storyboard ID.")
        }
    }
    
}
