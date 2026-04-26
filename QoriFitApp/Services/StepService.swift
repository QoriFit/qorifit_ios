//
//  StepService.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation
import Alamofire

class StepService {
    
    func getStepSummary(startDate: String, endDate: String? = nil,
                        completion: @escaping (Result<[StepsByDate], Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/step"
        
        var parameters: [String: Any] = ["startDate": startDate]
        if let end = endDate { parameters["endDate"] = end }
        
        AF.request(url, method: .get, parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: ApiService.shared.headers)
            .responseData { response in
                
                let decoder = JSONDecoder()
                
                switch response.result {
                case .success(let data):
                    do {
                        let apiResponse = try decoder.decode(ApiResponse<[StepsByDate]>.self, from: data)
                        
                        if apiResponse.code == 1000 {
                            // Desempaquetamos: si data es nil, mandamos array vacío
                            completion(.success(apiResponse.data ?? []))
                        } else {
                            completion(.failure(BusinessError(code: apiResponse.code, message: apiResponse.message ?? "Error")))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    if let data = response.data,
                       let apiResponse = try? decoder.decode(ApiResponse<[StepsByDate]>.self, from: data) {
                        completion(.failure(BusinessError(code: apiResponse.code, message: apiResponse.message ?? "Error")))
                    } else {
                        completion(.failure(error))
                    }
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
        
        var parameters: [String: Any] = ["startDate": startDate]
        if let end = endDate { parameters["endDate"] = end }
        
        AF.request(url, method: .get, parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: ApiService.shared.headers)
            .responseData { response in
                
                let decoder = JSONDecoder()
                
                switch response.result {
                case .success(let data):
                    do {
                        let apiResponse = try decoder.decode(ApiResponse<[StepRecordsPerDay]>.self, from: data)
                        
                        if apiResponse.code == 1000 {
                            // Desempaquetamos: si data es nil, mandamos array vacío
                            completion(.success(apiResponse.data ?? []))
                        } else {
                            let bizError = BusinessError(code: apiResponse.code, message: apiResponse.message ?? "Error en detalles")
                            completion(.failure(bizError))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    // Intentamos ver si el error trae un JSON de negocio (ej: 400 con código interno)
                    if let data = response.data,
                       let apiResponse = try? decoder.decode(ApiResponse<[StepRecordsPerDay]>.self, from: data) {
                        completion(.failure(BusinessError(code: apiResponse.code, message: apiResponse.message ?? "Error")))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
}

