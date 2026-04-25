//
//  AuthService.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation
import Alamofire

class AuthService {
    
    func login(email: String, pass: String, completion: @escaping (Bool) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/security/login"
        let parameters = ["email": email, "password": pass]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        // Aquí está el cambio: ApiResponse<LoginData>
                        let apiResponse = try decoder.decode(ApiResponse<LoginData>.self, from: data)
                        
                        let token = apiResponse.data.accessToken
                        ApiService.shared.saveToken(token: token)
                        
                        UserDefaults.standard.set(apiResponse.data.username, forKey: "user_name")
                        
                        CoreDataManager.shared.savePreferences(
                            steps: Int32(apiResponse.data.userData.stepsGoalPerDay),
                            calories: Int32(apiResponse.data.userData.maxCaloriesPerDay),
                            session: UUID(),
                            distUnit: "km",
                            weightUnit: "kg",
                            username: apiResponse.data.username
                        )
                        
                        print("Bienvenido")
                        completion(true)
                    } catch {
                        print("Error al parsear: \(error)")
                        completion(false)
                    }
                case .failure(let error):
                    print("Error red: \(error)")
                    completion(false)
                }
            }
    }
}
