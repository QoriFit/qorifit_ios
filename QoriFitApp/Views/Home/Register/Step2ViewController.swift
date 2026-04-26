//
//  Step2ViewController.swift
//  QoriFitApp
//
//  Created by XCODE on 25/04/26.
//

import UIKit

class Step2ViewController: UIViewController {

    var registrationDraft: RegisterParams!
        
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var lblCalories: UILabel!
    

    @IBOutlet weak var stpCalories: UIStepper!
    
    @IBOutlet weak var stpSteps: UIStepper!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupSteppers()
            updateLabels()
        }

        private func setupSteppers() {

            if registrationDraft.maxCalories == 0 {
                registrationDraft.maxCalories = 2000
            }
            
            if registrationDraft.stepsPerDay == 0 {
                registrationDraft.stepsPerDay = 5000
            }

            // 2. Sincronizar los Steppers físicos con los valores del draft
            stpCalories.value = Double(registrationDraft.maxCalories)
            stpSteps.value = Double(registrationDraft.stepsPerDay)
        }

        @IBAction func stepperCalChanged(_ sender: UIStepper) {
            // Actualizamos el draft con el nuevo valor del Stepper
            registrationDraft.maxCalories = Int(sender.value)
            updateLabels()
        }

        @IBAction func stepperStepsChanged(_ sender: UIStepper) {
            registrationDraft.stepsPerDay = Int(sender.value)
            updateLabels()
        }

        func updateLabels() {

            lblCalories.text = "\(registrationDraft.maxCalories) kcal"
            lblSteps.text = "\(registrationDraft.stepsPerDay) pasos"
        }

        @IBAction func nextPressed(_ sender: UIButton) {
            performSegue(withIdentifier: "toStep3", sender: nil)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let nextVC = segue.destination as? Step3ViewController {
                nextVC.registrationDraft = self.registrationDraft
            }
        }
    }
