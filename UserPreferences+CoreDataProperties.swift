//
//  UserPreferences+CoreDataProperties.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//
//

public import Foundation
public import CoreData


public typealias UserPreferencesCoreDataPropertiesSet = NSSet

extension UserPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreferences> {
        return NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
    }

    @NSManaged public var sessionId: UUID?
    @NSManaged public var unitWeight: String?
    @NSManaged public var unitDistance: String?
    @NSManaged public var caloriesGoal: Int16
    @NSManaged public var stepsGoal: Int16
    @NSManaged public var username: String?
    @NSManaged public var email: String?

}

extension UserPreferences : Identifiable {

}
