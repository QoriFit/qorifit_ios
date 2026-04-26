//
//  RegisterParams.swift
//  QoriFitApp
//
//  Created by XCODE on 25/04/26.
//

struct RegisterParams {
    var username: String = ""
    var maxCalories: Int = 2000
    var stepsPerDay: Int = 5000
    var weightUnit: String = "kg"
    var heightUnit: String = "m"
    var birthdate: String = ""
    var height: Double = 0.0
    var weight: Double = 0.0
    var email: String = ""
    var password: String = ""

    func toDictionary() -> [String: Any] {
        return [
            "username": username,
            "maxCaloriesPerDay": maxCalories,
            "stepsGoal": stepsPerDay,
            "birthDate": birthdate,
            "height": height,
            "weight": weight,
            "email": email,
            "password": password,
            "goal": "General"
        ]
    }
}
