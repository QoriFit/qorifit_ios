//
//  MealLogEntry.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//

import Foundation

struct MealLogEntry: Codable{
    let logId: Int32;
    let displayName: String;
    let totalCalories: Double;
}
