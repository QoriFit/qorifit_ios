//
//  Step4ViewController.swift
//  QoriFitApp
//
//  Created by XCODE on 25/04/26.
//

import UIKit

class Step4ViewController: UIViewController {

    var registrationDraft: RegisterParams!
    
    @IBOutlet weak var dpBirthDate: UIDatePicker!
    @IBOutlet weak var heightTF: UITextField!
    @IBOutlet weak var weightTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        heightTF.keyboardType = .decimalPad
        weightTF.keyboardType = .decimalPad
        dpBirthDate.maximumDate = Date()
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        // 1. Validamos que los campos no estén vacíos
        guard let h = heightTF.text, !h.isEmpty,
              let w = weightTF.text, !w.isEmpty else {
            showValidationAlert(message: "Por favor, ingresa tu altura y peso para continuar.")
            return
        }


        let cleanHeight = h.replacingOccurrences(of: ",", with: ".")
        let cleanWeight = w.replacingOccurrences(of: ",", with: ".")
        
        guard let heightDouble = Double(cleanHeight), heightDouble > 0,
              let weightDouble = Double(cleanWeight), weightDouble > 0 else {
            showValidationAlert(message: "Ingresa valores numéricos válidos y mayores a cero.")
            return
        }

        // 3. Si todo está OK, guardamos en el draft
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        registrationDraft.birthdate = formatter.string(from: dpBirthDate.date)
        registrationDraft.height = heightDouble
        registrationDraft.weight = weightDouble
        
        
        
        performSegue(withIdentifier: "toStep5", sender: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStep5" {
            if let nextVC = segue.destination as? Step5ViewController {
                nextVC.registrationDraft = self.registrationDraft
            }
        }
    }

    func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Faltan datos", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        self.present(alert, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
