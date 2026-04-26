//
//  Recipes.swift
//  QoriFitApp
//
//  Created by LifoX404 on 26/04/26.
//

import Foundation


struct CaloriesSummary: Codable {
    let date: String
    let totalCalories: Int
    let meals: [MealEntry]?
}

struct MealEntry: Codable {
    let mealName: String?
    let mealType: String?
    let totalCalories: Int?
}

// MARK: - Recipes (lista)

struct RecipeListItem: Codable {
    let recipeId: Int
    let name: String
    let description: String?
    let countryName: String?
    let imagePath: String?
    let estimatedCalories: Int?
    let popularity: Int?
}

// MARK: - Recipe (detalle)

struct RecipeDetail: Codable {
    let recipeId: Int?
    let name: String
    let description: String?
    let countryName: String?
    let imagePath: String?
    let estimatedCalories: Int?
    let totalCalories: Int?
    let popularity: Int?
    let instructions: String?
    let ingredients: [RecipeIngredient]?
}

struct RecipeIngredient: Codable {
    let id: Int?
    let name: String
    let quantity: Int?
    let calories: Int?
}
