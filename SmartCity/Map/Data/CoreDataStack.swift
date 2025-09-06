//
//  CoreDataStack.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmartCityData")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                //TODO: remove fatal
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                //TODO: remove fatal
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveCities(_ cities: CitiesResponse) async {
        let backgroundContext = persistentContainer.newBackgroundContext()
        
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
