//
//  Step3ViewController.swift
//  QoriFitApp
//
//  Created by XCODE on 25/04/26.
//

import UIKit

class Step3ViewController: UIViewController {

    var registrationDraft: RegisterParams!
        
        // Suponiendo que usas UISegmentedControl para Kilos/Libras y Metros/Pies
        @IBOutlet weak var weightSegment: UISegmentedControl!
        @IBOutlet weak var heightSegment: UISegmentedControl!

        @IBAction func nextPressed(_ sender: UIButton) {
            registrationDraft.weightUnit = weightSegment.selectedSegmentIndex == 0 ? "kg" : "lb"
            registrationDraft.heightUnit = heightSegment.selectedSegmentIndex == 0 ? "m" : "ft"
            performSegue(withIdentifier: "toStep4", sender: nil)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let nextVC = segue.destination as? Step4ViewController {
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
