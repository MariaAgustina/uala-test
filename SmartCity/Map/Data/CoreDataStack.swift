//
//  CoreDataStack.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation
import CoreData

enum CoreDataError: Error {
    case persistentStoreLoadingFailed(Error)
    case saveFailed(Error)
}

final class CoreDataStack {
    
    private var _persistentContainer: NSPersistentContainer?
    private var loadError: Error?
    
    var persistentContainer: NSPersistentContainer {
        get throws {
            if let error = loadError {
                throw CoreDataError.persistentStoreLoadingFailed(error)
            }
            
            if let container = _persistentContainer {
                return container
            }
            
            let container = NSPersistentContainer(name: "SmartCityData")
            container.loadPersistentStores { _, error in
                if let error = error {
                    self.loadError = error
                    print("❌ CoreData loading failed: \(error)")
                } else {
                    self._persistentContainer = container
                    print("✅ CoreData loaded successfully")
                }
            }
            
            if let error = loadError {
                throw CoreDataError.persistentStoreLoadingFailed(error)
            }
            
            return container
        }
    }
    
    var context: NSManagedObjectContext {
        get throws {
            return try persistentContainer.viewContext
        }
    }
    
    func saveContext() throws {
        let context = try persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Context save failed: \(error)")
                throw CoreDataError.saveFailed(error)
            }
        }
    }
    
    func saveCities(_ cities: CitiesResponse) async throws {
        let backgroundContext = try persistentContainer.newBackgroundContext()
        
        await backgroundContext.perform {
            print("💿 Processing \(cities.count) cities for CoreData...")
            
            // Primero borrar todas las ciudades existentes
            let deleteRequest: NSFetchRequest<NSFetchRequestResult> = City.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: deleteRequest)
            
            do {
                try backgroundContext.execute(batchDeleteRequest)
                print("🗑️ Cleared all existing cities from CoreData")
            } catch {
                print("❌ Error clearing cities: \(error)")
            }
            
            // Ahora insertar todas las ciudades nuevas
            for cityResponse in cities {
                let city = City(context: backgroundContext)
                city.id = Int32(cityResponse.id)
                city.name = cityResponse.name
                city.country = cityResponse.country
                city.latitude = cityResponse.coord.lat
                city.longitude = cityResponse.coord.lon
            }
            
            do {
                print("💿 Saving \(cities.count) cities to CoreData...")
                try backgroundContext.save()
                print("✅ CoreData save completed successfully")
            } catch {
                print("❌ Failed to save cities: \(error)")
            }
        }
    }
}
