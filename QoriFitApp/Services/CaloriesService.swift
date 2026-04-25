//
//  CaloriesService.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//

import Foundation
import Alamofire

class CaloriesService {
    
    func getCaloriesSummary(date: String, completion: @escaping (Result<CaloriesSummary, Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/calories/summary"
        let parameters = ["date": date]
        
        AF.request(url, method: .get, parameters: parameters, headers: ApiService.shared.headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let apiResponse = try decoder.decode(ApiResponse<CaloriesSummary>.self, from: data)
                        // ESTÁNDAR: Devolvemos .success
                        completion(.success(apiResponse.data))
                    } catch {
                        print("Error decodificando calorías: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error de red en calorías: \(error)")
                    completion(.failure(error))
                }
            }
    }
}
