//
//  ViewController.swift
//  QoriFitApp
//
//  Created by Apple on 9/04/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func btnGetStarted(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        
        let registerVC = storyboard.instantiateViewController(withIdentifier: "InitialRegisterViewController")
        
        registerVC.modalPresentationStyle = .fullScreen
        registerVC.modalTransitionStyle = .crossDissolve

        self.present(registerVC, animated: true)
    }
    
}

