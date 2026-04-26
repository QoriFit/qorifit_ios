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
        
        // Validación rápida antes de llamar al service (Toque de calidad)
        guard !email.isEmpty, !pass.isEmpty else {
            self.showAlert(message: "Por favor, completa todos los campos")
            return
        }
        
        let authService = AuthService()
        
        authService.login(email: email, pass: pass) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Login exitoso para: \(data.username)")
                    self?.goToHome()
                    
                case .failure(let error):
                    // ERROR es ahora tipo BusinessError.
                    // Ya tiene el 'code' y el 'message' que extrajimos del JSON (incluso si fue 400)
                    
                    if error.code == 1012 {
                        self?.showAlert(title: "Advertencia", message: error.message)
                    } else if error.code == -1 {
                        self?.showAlert(title: "Sin conexión", message: "Revisa tu internet")
                    } else {
                        self?.showAlert(title: "Aviso \(error.code)", message: error.message)
                    }
                }
            }
        }
    }
    
    func goToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)

        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainHomeViewController") as? UITabBarController {
            
            tabBarVC.modalPresentationStyle = .fullScreen
            tabBarVC.modalTransitionStyle = .crossDissolve
            
            DispatchQueue.main.async {
                self.present(tabBarVC, animated: true, completion: nil)
            }
        }
        
        
    }
    

    
}
