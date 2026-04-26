//
//  UserPreferences+CoreDataProperties.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//
//

public import Foundation
public import CoreData


public typealias UserPreferencesCoreDataPropertiesSet = NSSet

extension UserPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreferences> {
        return NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
    }

    @NSManaged public var caloriesGoal: Int32
    @NSManaged public var email: String?
    @NSManaged public var sessionId: UUID?
    @NSManaged public var stepsGoal: Int32
    @NSManaged public var unitDistance: String?
    @NSManaged public var unitWeight: String?
    @NSManaged public var username: String?
    @NSManaged public var age: Int32
    @NSManaged public var weight: Double
    @NSManaged public var height: Int32

}

extension UserPreferences : Identifiable {

}
