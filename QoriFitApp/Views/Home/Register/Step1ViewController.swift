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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
