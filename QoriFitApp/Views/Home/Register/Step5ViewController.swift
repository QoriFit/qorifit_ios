//
//  Step5ViewController.swift
//  QoriFitApp
//
//  Created by XCODE on 25/04/26.
//

import UIKit

class Step5ViewController: UIViewController {
    
    let authService = AuthService()
    
    var registrationDraft: RegisterParams!
        
        @IBOutlet weak var emailTF: UITextField!
        @IBOutlet weak var passwordTF: UITextField!
        @IBOutlet weak var RepeatPass: UITextField!
        @IBOutlet weak var btnListo: UIButton!

    @IBAction func btnListoPressed(_ sender: UIButton) {
        guard let email = emailTF.text, !email.isEmpty,
              let pass = passwordTF.text, !pass.isEmpty else {
            self.showAlert(message: "Por favor, completa todos los campos")
            return
        }
        

        registrationDraft.email = email
        registrationDraft.password = pass
        
        btnListo.isEnabled = false
        
        let authService = AuthService()
        

        authService.register(params: registrationDraft.toDictionary()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loginData):
                    print("Registro y Login exitoso para: \(loginData.username)")

                    self?.goToHome()
                    
                case .failure(let error):
                    self?.btnListo.isEnabled = true
                    
                    // Ahora podemos usar tus códigos internos (ej: 1015 para email duplicado)
                    let titulo = "Error \(error.code)"
                    let mensaje = error.message
                    
                    self?.showAlert(title: titulo, message: mensaje)
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
