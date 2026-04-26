//
//  BusinessError.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//

import Foundation


struct BusinessError: Error {
    let code: Int
    let message: String
}
