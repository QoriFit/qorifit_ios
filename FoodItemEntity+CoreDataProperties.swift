//
//  FoodItemEntity+CoreDataProperties.swift
//  QoriFitApp
//
//  Created by LifoX404 on 25/04/26.
//
//

public import Foundation
public import CoreData


public typealias FoodItemEntityCoreDataPropertiesSet = NSSet

extension FoodItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItemEntity> {
        return NSFetchRequest<FoodItemEntity>(entityName: "FoodItemEntity")
    }

    @NSManaged public var foodDesc: String?
    @NSManaged public var id: Int32
    @NSManaged public var imageName: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var kcal: Int32
    @NSManaged public var name: String?

}

extension FoodItemEntity : Identifiable {

}
