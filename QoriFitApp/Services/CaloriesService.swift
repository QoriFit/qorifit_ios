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
        
        var parameters: [String: Any] = [
            "startDate": startDate
        ]
        
        // 2. Agregamos el opcional si viene
        if let end = endDate {
            parameters["endDate"] = end
        }
        
        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: ApiService.shared.headers)
            .validate() // Recomendado para capturar errores 4xx o 5xx antes de decodificar
            .responseData { response in
                
                // Debug: para que veas qué llega en la consola de Xcode
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("JSON Calorías recibido: \(str)")
                }
                
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        // Si tu backend usa el formato estándar, decodificamos la lista
                        let apiResponse = try decoder.decode(ApiResponse<[MealSummaryByDate]>.self, from: data)
                        
                        completion(.success(apiResponse.data))
                    } catch {
                        print("Error decodificando calorías: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error de red en calorías: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
}
