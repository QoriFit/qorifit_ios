//
//  StepRecordsPerDay.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//

import Foundation

struct StepRecordsPerDay: Codable{
    
    let date: String;
    let records: [StepRecord];
    let totalStepsPerDay: Int32;
    
}
