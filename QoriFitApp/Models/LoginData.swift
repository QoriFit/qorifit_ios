//
//  LoginData.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation

struct LoginData: Codable {
    let username: String
    let email: String
    let accessToken: String
    let userData: UserSettings
}

struct UserSettings: Codable {
    let profilePicture: String?
    let stepsGoalPerDay: Int
    let maxCaloriesPerDay: Int
    let birthDate: String
    let goal: String?
}
