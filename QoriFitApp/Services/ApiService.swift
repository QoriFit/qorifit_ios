//
//  ApiService.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation
import Alamofire


final class ApiService {
    
    static let shared = ApiService()
    let baseUrl = "https://qorifit-backend.onrender.com/api/qorifit"

    var headers: HTTPHeaders {
        // Recuperamos el token guardado
        let savedToken = UserDefaults.standard.string(forKey: "user_jwt") ?? ""
        
        return [
            "Authorization": "Bearer \(savedToken)",
            "Accept": "application/json"
        ]
    }
    
    private init() {}
    
    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: "user_jwt")
    }
}
