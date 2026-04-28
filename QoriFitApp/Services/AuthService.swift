//
//  AuthService.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation
import Alamofire

class AuthService {

    func login(email: String, pass: String, completion: @escaping (Result<LoginData, BusinessError>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/security/login"
        let parameters = ["email": email, "password": pass]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseData { response in
                let decoder = JSONDecoder()
                let apiResponse = try? decoder.decode(ApiResponse<LoginData>.self, from: response.data ?? Data())
                
                switch response.result {
                case .success:
                    if let res = apiResponse, res.code == 1000, let data = res.data {
                        self.saveUserSession(data)
                        completion(.success(data))
                    } else {
                        completion(.failure(BusinessError(code: apiResponse?.code ?? 0, message: apiResponse?.message ?? "Error")))
                    }
                case .failure(let error):
                    if let res = apiResponse {
                        completion(.failure(BusinessError(code: res.code, message: res.message ?? "Error de negocio")))
                    } else {
                        completion(.failure(BusinessError(code: -1, message: error.localizedDescription)))
                    }
                }
            }
    }
    
    
    func register(params: [String: Any], completion: @escaping (Result<LoginData, BusinessError>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/security/register"
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseData { response in
                // Print del Request (URL, Headers y Body)
                if let requestBody = response.request?.httpBody,
                   let jsonString = String(data: requestBody, encoding: .utf8) {
                    print("Request URL: \(url)")
                    print("Request Body: \(jsonString)")
                }

                // Print del Response (Cuerpo de la respuesta)
                if let data = response.data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("Response Raw Data: \(responseString)")
                }

                let decoder = JSONDecoder()
                let apiResponse = try? decoder.decode(ApiResponse<LoginData>.self, from: response.data ?? Data())
                
                switch response.result {
                case .success:
                    if let res = apiResponse, res.code == 1000, let data = res.data {
                        self.saveUserSession(data)
                        completion(.success(data))
                    } else {
                        let code = apiResponse?.code ?? 0
                        let msg = apiResponse?.message ?? "Error en registro"
                        completion(.failure(BusinessError(code: code, message: msg)))
                    }
                case .failure(let error):
                    if let res = apiResponse {
                        completion(.failure(BusinessError(code: res.code, message: res.message ?? "Error de negocio")))
                    } else {
                        completion(.failure(BusinessError(code: -1, message: error.localizedDescription)))
                    }
                }
            }
    }
    private func saveUserSession(_ data: LoginData) {

        ApiService.shared.saveToken(token: data.accessToken)
        UserDefaults.standard.set(data.username, forKey: "user_name")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let birthDateConverted = formatter.date(from: data.userData.birthDate) ?? Date()
        
        CoreDataManager.shared.savePreferences(
            steps: Int32(data.userData.stepsGoalPerDay),
            calories: Int32(data.userData.maxCaloriesPerDay),
            session: UUID(),
            distUnit: "km",
            weightUnit: "kg",
            username: data.username,
            email: data.email,
            high: data.userData.height,
            weight: data.userData.weight,
            birthdate: birthDateConverted
        )
    }
}
