//
//  StepService.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation
import Alamofire

class StepService {
    
    func getStepSummary(startDate: String, endDate: String? = nil, completion: @escaping (Result<[StepsByDate], Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/step"
        
        var parameters: [String: Any] = [
                "startDate": startDate
            ]
        
        if let end = endDate {
                parameters["endDate"] = end
            }
        
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: ApiService.shared.headers)
        .validate()
        .responseData { response in
            
            if let data = response.data, let str = String(data: data, encoding: .utf8) {
                print("Contenido real recibido: \(str)")
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    
                    let apiResponse = try decoder.decode(ApiResponse<[StepsByDate]>.self, from: data)
                    
                    // CORRECCIÓN: Envolvemos el resultado en .success
                    completion(.success(apiResponse.data))
                    
                } catch {
                    print("Error decodificando pasos: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Error de red en StepService: \(error.localizedDescription)")
                // CORRECCIÓN: Envolvemos el error en .failure
                completion(.failure(error))
            }
        }
    }
    
    func registerSteps(date: String, stepCount: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/step"
        let parameters: [String: Any] = [
            "date": date,
            "stepCount": stepCount
        ]

        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: ApiService.shared.headers)
        .validate(statusCode: 200..<300)
        .response { response in
            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getStepsDetails(startDate: String, endDate: String? = nil,
                         completion: @escaping (Result<[StepRecordsPerDay], Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/step/details"
        
        var parameters: [String: Any] = [
            "startDate": startDate
        ]
        
        if let end = endDate {
            parameters["endDate"] = end
        }
        
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: ApiService.shared.headers)
        .validate()
        .responseData { response in
            
            if let data = response.data, let str = String(data: data, encoding: .utf8) {
                print("Contenido real recibido: \(str)")
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    
                    let apiResponse = try decoder.decode(ApiResponse<[StepRecordsPerDay]>.self, from: data)
                    
                    // CORRECCIÓN: Envolvemos el resultado en .success
                    completion(.success(apiResponse.data))
                    
                } catch {
                    print("Error decodificando pasos: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Error de red en StepService: \(error.localizedDescription)")
                // CORRECCIÓN: Envolvemos el error en .failure
                completion(.failure(error))
            }
        }
        
        
    }
}

