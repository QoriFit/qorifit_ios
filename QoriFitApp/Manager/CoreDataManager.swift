//
//  CoreDataManager.swift
//  QoriFitApp
//
//  Created by LifoX404 on 24/04/26.
//

import Foundation
import CoreData
import UIKit

struct FoodItem {
    let id: Int
    let name: String
    let kcal: Int
    let imageName: String
    let description: String
    var isFavorite: Bool
}

class CoreDataManager {
    static let shared = CoreDataManager()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Error al guardar contexto: \(error)")
        }
    }

    // Guardar o Actualizar preferencias
    func savePreferences(steps: Int32, calories: Int32, session: UUID, distUnit: String, weightUnit: String, username: String, email: String, high:Int32, weight: Double) {
        let fetchRequest: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            let prefs = results.first ?? UserPreferences(context: context)
            
            prefs.stepsGoal = steps
            prefs.caloriesGoal = calories
            prefs.sessionId = session
            prefs.unitDistance = distUnit
            prefs.unitWeight = weightUnit
            prefs.username = username
            prefs.email = email
            prefs.height = high
            prefs.weight = weight
            
            try context.save()
            print("Datos guardados en Core Data")
        } catch {
            print("Error al guardar en Core Data: \(error)")
        }
    }

    func getPreferences() -> UserPreferences? {
        let fetchRequest: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        return try? context.fetch(fetchRequest).first
    }
    
    func deleteAllPreferences() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserPreferences.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Core Data limpio para el próximo login")
        } catch {
            print("Error al borrar preferencias: \(error)")
        }
    }
    
    // MARK: - Seed (carga inicial de recetas)
    /// Llama esto una vez al arrancar la app (desde AppDelegate o SceneDelegate)
    func seedFoodsIfNeeded() {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FoodItemEntity")
        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return } // ya tiene datos, no volver a insertar

        let initialFoods: [FoodItem] = [
            FoodItem(id: 1, name: "Quinoa con crudités",       kcal: 320, imageName: "quinoa",     description: "Ensalada de quinoa cocida con zanahoria, pepino, pimiento y aderezo de limón. Rica en proteínas vegetales y fibra.", isFavorite: false),
            FoodItem(id: 2, name: "Macarrones con gambas",     kcal: 480, imageName: "macarrones", description: "Pasta con gambas salteadas en aceite de oliva, ajo, tomate cherry y perejil fresco.", isFavorite: false),
            FoodItem(id: 3, name: "Pepinos rellenos de arroz", kcal: 280, imageName: "pepinos",    description: "Pepinos vaciados y rellenos de arroz integral con hierbas, muy refrescante.", isFavorite: false),
            FoodItem(id: 4, name: "Judías verdes con patata",  kcal: 350, imageName: "judias",     description: "Guiso tradicional de judías verdes con patata y sepia, alto en fibra y proteínas.", isFavorite: false),
            FoodItem(id: 5, name: "Ensalada de aguacate",      kcal: 390, imageName: "aguacate",   description: "Mezcla de lechugas, aguacate, tomate, cebolla morada y vinagreta balsámica.", isFavorite: false),
            FoodItem(id: 6, name: "Pollo a la plancha",        kcal: 420, imageName: "pollo",      description: "Pechuga de pollo a la plancha con limón, romero y guarnición de verduras asadas.", isFavorite: false),
        ]

        initialFoods.forEach { insert(food: $0) }
        saveContext()
        print("✅ CoreData: \(initialFoods.count) recetas cargadas")
    }

    // MARK: - INSERT
    private func insert(food: FoodItem) {
        guard let entity = NSEntityDescription.entity(forEntityName: "FoodItemEntity", in: context) else { return }
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(food.id,          forKey: "id")
        object.setValue(food.name,        forKey: "name")
        object.setValue(food.kcal,        forKey: "kcal")
        object.setValue(food.imageName,   forKey: "imageName")
        object.setValue(food.description, forKey: "foodDesc")
        object.setValue(food.isFavorite,  forKey: "isFavorite")
    }

    // MARK: - FETCH ALL
    func fetchAllFoods() -> [FoodItem] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FoodItemEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            let results = try context.fetch(request)
            return results.map { mapToFoodItem($0) }
        } catch {
            print("Error al obtener recetas: \(error)")
            return []
        }
    }

    // MARK: - FETCH FAVORITES
    func fetchFavorites() -> [FoodItem] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FoodItemEntity")
        request.predicate       = NSPredicate(format: "isFavorite == true")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let results = try context.fetch(request)
            return results.map { mapToFoodItem($0) }
        } catch {
            print("Error al obtener favoritos: \(error)")
            return []
        }
    }

    // MARK: - TOGGLE FAVORITE
    func toggleFavorite(foodId: Int) {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FoodItemEntity")
        request.predicate = NSPredicate(format: "id == %d", foodId)
        do {
            if let object = try context.fetch(request).first {
                let current = object.value(forKey: "isFavorite") as? Bool ?? false
                object.setValue(!current, forKey: "isFavorite")
                saveContext()
            }
        } catch {
            print("Error al cambiar favorito: \(error)")
        }
    }

    // MARK: - MAP helper
    private func mapToFoodItem(_ object: NSManagedObject) -> FoodItem {
        return FoodItem(
            id:          object.value(forKey: "id")         as? Int    ?? 0,
            name:        object.value(forKey: "name")       as? String ?? "",
            kcal:        object.value(forKey: "kcal")       as? Int    ?? 0,
            imageName:   object.value(forKey: "imageName")  as? String ?? "",
            description: object.value(forKey: "foodDesc")   as? String ?? "",
            isFavorite:  object.value(forKey: "isFavorite") as? Bool   ?? false
        )
    }
}
