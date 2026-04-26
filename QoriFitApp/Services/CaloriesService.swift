//
//  CaloriesService.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//

import Foundation
import Alamofire

class CaloriesService {
    
    func getCaloriesSummary(startDate: String, endDate: String? = nil, completion: @escaping (Result<[MealSummaryByDate], Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/calories/summary"
        
        var parameters: [String: Any] = ["startDate": startDate]
        if let end = endDate {
            parameters["endDate"] = end
        }
        
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: ApiService.shared.headers)
            .responseData { response in
                
                // Debug para ver qué llega
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("JSON Calorías recibido: \(str)")
                }
                
                let decoder = JSONDecoder()
                
                switch response.result {
                case .success(let data):
                    do {
                        // 1. Decodificamos primero
                        let apiResponse = try decoder.decode(ApiResponse<[MealSummaryByDate]>.self, from: data)
                        
                        // 2. Validamos tu código interno 1000
                        if apiResponse.code == 1000 {
                            // 3. Como 'data' es opcional, usamos el operador ?? para devolver array vacío si es nil
                            let meals = apiResponse.data ?? []
                            completion(.success(meals))
                        } else {
                            // Si no es 1000, devolvemos un error de negocio
                            let error = NSError(domain: "", code: apiResponse.code, userInfo: [NSLocalizedDescriptionKey: apiResponse.message ?? "Error desconocido"])
                            completion(.failure(error))
                        }
                        
                    } catch {
                        print("Error decodificando calorías: \(error)")
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
