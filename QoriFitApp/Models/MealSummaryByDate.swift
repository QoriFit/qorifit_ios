//
//  MealSummaryByDate.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//

import Foundation

struct MealSummaryByDate: Codable{
    let date: String;
    let meals: [MealLogEntry];
    let totalCalories: Double;
}
