//
//  RecipeService.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation
import Alamofire

class RecipeService {
    func getRecipes(completion: @escaping ([RecipeItem]?) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/recipes"
        
        AF.request(url, method: .get, headers: ApiService.shared.headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let apiResponse = try decoder.decode(ApiResponse<[RecipeItem]>.self, from: data)
                        completion(apiResponse.data)
                    } catch {
                        print("Error decodificando: \(error)")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Error de red: \(error)")
                    completion(nil)
                }
            }
    }
}
