//
//  Step1ViewController.swift
//  QoriFitApp
//
//  Created by XCODE on 25/04/26.
//

import UIKit

class Step1ViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
        var registrationDraft = RegisterParams()

    @IBAction func nextPressed(_ sender: UIButton) {
            guard let name = nameTextField.text, !name.isEmpty else { return }
            registrationDraft.username = name
            performSegue(withIdentifier: "toStep2", sender: nil)
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let nextVC = segue.destination as? Step2ViewController {
                nextVC.registrationDraft = self.registrationDraft
        }
    }


    @IBAction func btnBack(_ sender: Any) {
        
        goToMain()
    }
    
    func goToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let mainVc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        
        mainVc.modalPresentationStyle = .fullScreen
        mainVc.modalTransitionStyle = .crossDissolve
        
        DispatchQueue.main.async {
            self.present(mainVc, animated: true, completion: nil)
        }
    }
}
