//
//  LoginViewController.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    
    @IBAction func btnLogIn(_ sender: UIButton) {
        
        let email = txtEmail.text ?? ""
            let pass = txtPassword.text ?? ""
            
            let authService = AuthService()
            
        authService.login(email: email, pass: pass) { [weak self] success in

            DispatchQueue.main.async {
                if success {
                    self?.goToHome()
                } else {
                    print("Credenciales incorrectas")
                }
            }
        }
    }
    
    func goToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        // Instanciamos el TAB BAR (el contenedor de todas las pestañas)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainHomeViewController") as? UITabBarController {
            
            tabBarVC.modalPresentationStyle = .fullScreen
            tabBarVC.modalTransitionStyle = .crossDissolve
            
            // Siempre en el hilo principal para evitar el crash
            DispatchQueue.main.async {
                self.present(tabBarVC, animated: true, completion: nil)
            }
        }
    }
    

}
