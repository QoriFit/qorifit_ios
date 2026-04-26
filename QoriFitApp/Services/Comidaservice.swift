//
//  Comidaservice.swift
//  QoriFitComida
//
//  Created by XCODE on 25/04/26.
//

import Foundation
import Alamofire

class ComidaService {
    static let shared = ComidaService()

    func fetchCaloriesSummary(date: String, completion: @escaping (Result<CaloriesSummary, Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/calories/summary"
        let parameters: [String: String] = ["startDate": date]

        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.queryString,
                   headers: ApiService.shared.headers)
        .responseData { response in
            if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                print("📦 Calories summary: \(raw)")
            }

            guard let data = response.data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }

            // data es un array, tomamos el primer elemento
            if let apiResponse = try? JSONDecoder().decode(ApiResponse<[CaloriesSummary]>.self, from: data),
               let summaries = apiResponse.data,
               let first = summaries.first {
                completion(.success(first))
                return
            }

            // Fallback: intentar como objeto directo
            if let apiResponse = try? JSONDecoder().decode(ApiResponse<CaloriesSummary>.self, from: data),
               let summary = apiResponse.data {
                completion(.success(summary))
                return
            }

            completion(.failure(URLError(.cannotParseResponse)))
        }
    }

    // MARK: - POST /calories
    // Registra una comida con receta

    func registerMeal(recipeId: Int, mealName: String, mealType: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/calories"
        let parameters: [String: Any] = [
            "recipeId": recipeId,
            "mealName": mealName,
            "mealType": mealType
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

    // MARK: - GET /recipes
    // Lista recetas

    func fetchRecipes(completion: @escaping (Result<[RecipeListItem], Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/recipes"

        AF.request(url,
                   method: .get,
                   headers: ApiService.shared.headers)
        .responseData { response in
            if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                print("📦 Recipes: \(raw)")
            }

            guard let data = response.data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }

            if let apiResponse = try? JSONDecoder().decode(ApiResponse<[RecipeListItem]>.self, from: data),
               let recipes = apiResponse.data {
                completion(.success(recipes))
                return
            }

            completion(.success([]))
        }
    }

    // MARK: - GET /recipes/{id}
    // Detalle de una receta

    func fetchRecipeDetail(id: Int, completion: @escaping (Result<RecipeDetail, Error>) -> Void) {
        let url = "\(ApiService.shared.baseUrl)/recipes/\(id)"

        AF.request(url,
                   method: .get,
                   headers: ApiService.shared.headers)
        .responseData { response in
            if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                print("📦 Recipe detail: \(raw)")
            }

            guard let data = response.data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }

            if let apiResponse = try? JSONDecoder().decode(ApiResponse<RecipeDetail>.self, from: data),
               let detail = apiResponse.data {
                completion(.success(detail))
                return
            }

            completion(.failure(URLError(.cannotParseResponse)))
        }
    }

    // MARK: - Helpers

    static func todayISO() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
