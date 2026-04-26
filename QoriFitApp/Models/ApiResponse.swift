//
//  ApiResponse.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation

struct ApiResponse<T: Codable>: Codable{
    
    let code: Int;
    let message: String?;
    let data: T?;
}
