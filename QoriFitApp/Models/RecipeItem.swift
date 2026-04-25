//
//  RecipeItem.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation

struct RecipeItem: Codable{
    var recipeId: Int;
    var name: String;
    var description: String;
    var countryName: String;
    var imagePath: String;
    var estimatedCalories: Int;
    
}
