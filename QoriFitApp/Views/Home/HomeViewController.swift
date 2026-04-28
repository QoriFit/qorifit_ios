//
//  HomeViewController.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet weak var lblGreetings: UILabel!
    @IBOutlet weak var pbStepsToday: UIProgressView!
    @IBOutlet weak var pbCaloriesToday: UIProgressView!
    
    @IBOutlet weak var lblCurrentDate: UILabel!
    @IBOutlet weak var lblTodayStepsCount: UILabel!
    @IBOutlet weak var lblTodayCaloriesCount: UILabel!
    
    let stepService = StepService()
    let mealService = ComidaService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentDate()
        setupGreetings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDashboardData()
    }
    
    private func setupUI() {
        // Configuramos el grosor de ambas barras (pbStepsToday y pbCaloriesToday)
        [pbStepsToday, pbCaloriesToday].forEach { pb in
            pb?.transform = pb?.transform.scaledBy(x: 1, y: 10) ?? .identity
            pb?.layer.cornerRadius = 8
            pb?.clipsToBounds = true
            pb?.subviews.forEach { $0.clipsToBounds = true }
            if let fillLayer = pb?.subviews.last {
                fillLayer.layer.cornerRadius = 8
            }
        }
    }
    
    func refreshDashboardData() {
        guard let prefs = CoreDataManager.shared.getPreferences() else { return }
        
        let metaPasos = Int(prefs.stepsGoal)
        let metaCalorias = Double(prefs.caloriesGoal)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        // 1. Cargar Pasos
        stepService.getStepSummary(startDate: today) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lista):
                    let actuales = lista.first?.steps ?? 0
                    self?.updateProgress(pb: self?.pbStepsToday, lbl: self?.lblTodayStepsCount, current: Double(actuales), goal: Double(metaPasos), suffix: "pasos")
                case .failure:
                    self?.updateProgress(pb: self?.pbStepsToday, lbl: self?.lblTodayStepsCount, current: 0, goal: Double(metaPasos), suffix: "pasos")
                }
            }
        }
        
        // 2. Cargar Calorías usando tu nuevo servicio
        mealService.fetchCaloriesSummary(date: today) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let summary):
                    // Usamos totalCalories que viene de tu backend
                    let caloriasConsumidas = summary.totalCalories
                    self?.updateProgress(pb: self?.pbCaloriesToday, lbl: self?.lblTodayCaloriesCount, current: Double(caloriasConsumidas), goal: metaCalorias, suffix: "kcal")
                case .failure(let error):
                    print("Error en resumen de calorías: \(error)")
                    self?.updateProgress(pb: self?.pbCaloriesToday, lbl: self?.lblTodayCaloriesCount, current: 0, goal: metaCalorias, suffix: "kcal")
                }
            }
        }
    }

    func updateProgress(pb: UIProgressView?, lbl: UILabel?, current: Double, goal: Double, suffix: String) {
        let percent = goal > 0 ? Float(current / goal) : 0
        pb?.setProgress(percent, animated: true)
        
        lbl?.text = "\(Int(current)) / \(Int(goal)) \(suffix)"
        
        if current >= goal && goal > 0 {
            pb?.progressTintColor = .systemGreen
        } else {
            // Azul para pasos, Naranja para calorías (estilo QoriFit)
            pb?.progressTintColor = (suffix == "pasos") ? .systemBlue : .systemOrange
        }
    }
    
    func loadCurrentDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        let fechaHoy = formatter.string(from: Date())
        lblCurrentDate.text = fechaHoy.capitalized
    }
    
    private func setupGreetings() {
        // 1. Obtener preferencias para el nombre
        if let prefs = CoreDataManager.shared.getPreferences() {
            lblUsername.text = prefs.username ?? "Usuario"
        }
        
        // 2. Determinar el saludo según la hora
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 4..<12:
            lblGreetings.text = "Buenos días ☀️"
        case 12..<18:
            lblGreetings.text = "Buenas tardes 🌅"
        default: // De 18:00 a 3:59
            lblGreetings.text = "Buenas noches 🌙"
        }
    }
}
