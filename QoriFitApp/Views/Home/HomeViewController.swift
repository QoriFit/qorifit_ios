//
//  HomeViewController.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var lblCurrentDate: UILabel!
    
    @IBOutlet weak var lblTodayStepsCount: UILabel!
    @IBOutlet weak var lblTodayCalories: UILabel!
    let stepService = StepService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupHomeData()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupHomeData()
        loadCurrentDate()
        
        loadTodaySteps()
        
        loadTodayCalories()
        

    }
    
    func setupHomeData() {
        var metaPasos: Int = 0
        if let prefs = CoreDataManager.shared.getPreferences() {
            metaPasos = Int(prefs.stepsGoal)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())

        // El cambio principal está en cómo manejamos el 'result'
        stepService.getStepSummary(startDate: currentDate) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let listaPasos):
                    // Accedemos al primer elemento del array.
                    // OJO: Asegúrate si es .steps o .stepCount según tu modelo
                    let pasosActuales = listaPasos.first?.steps ?? 0
                    self?.updateStepsUI(current: pasosActuales, goal: metaPasos)
                    
                case .failure(let error):
                    print("Error al obtener pasos: \(error)")
                    // En caso de error, mostramos 0 o lo que prefieras
                    self?.updateStepsUI(current: 0, goal: metaPasos)
                }
            }
        }
    }

    func updateStepsUI(current: Int, goal: Int) {
        // Formateamos el string para que se vea "Actual / Meta"
        lblTodayStepsCount.text = "\(current) / \(goal)"
        
        // Opcional: Si quieres ponerle un color diferente si llegó a la meta
        if current >= goal && goal > 0 {
            lblTodayStepsCount.textColor = .systemGreen
        } else {
            lblTodayStepsCount.textColor = .label // Color de texto estándar
        }
    }
    
    func loadTodaySteps() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())
        
        stepService.getStepSummary(startDate: currentDate) { result in

            switch result {
            case .success(let lista):
                print("¡Pasos cargados correctamente!: \(lista.count)")
                // Aquí puedes hacer algo con la lista si lo necesitas
                
            case .failure(let error):
                print("Error de red o de parseo: \(error.localizedDescription)")
            }
        }
    }
    
    func loadTodayCalories(){
        
    }
    
    
    func loadCurrentDate() -> Void{
        let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_PE")
            formatter.dateFormat = "EEEE, d 'de' MMMM"
            let fechaHoy = formatter.string(from: Date())
            lblCurrentDate.text = fechaHoy.capitalized
        
    }
    
    
    


}
