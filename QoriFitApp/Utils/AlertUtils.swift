//
//  AlertUtils.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String = "Aviso", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
