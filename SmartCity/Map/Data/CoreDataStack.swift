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

protocol CoreDataStackProtocol {
    var container: NSPersistentContainer { get }
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func load() async throws
    func saveIfNeeded() throws
    func saveCities(_ cities: CitiesResponse) async throws
}

final class CoreDataStack: CoreDataStackProtocol {
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }

    init(modelName: String = "SmartCityData") {
        container = NSPersistentContainer(name: modelName)
        for d in container.persistentStoreDescriptions {
            d.shouldMigrateStoreAutomatically = true
            d.shouldInferMappingModelAutomatically = true
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func load() async throws {
        try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let e = error { c.resume(throwing: e) } else { c.resume(returning: ()) }
            }
        }
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }

    func saveIfNeeded() throws {
        if viewContext.hasChanges { try viewContext.save() }
    }
    
    func saveCities(_ cities: CitiesResponse) async throws {
        let ctx = newBackgroundContext()
        try await ctx.performAsync { ctx in
            let fetch: NSFetchRequest<NSFetchRequestResult> = City.fetchRequest()
            let deleteReq = NSBatchDeleteRequest(fetchRequest: fetch)
            try ctx.execute(deleteReq)

            var i = 0
            let insert = NSBatchInsertRequest(entity: City.entity()) { (row: NSManagedObject) -> Bool in
                guard i < cities.count else { return true }
                let c = cities[i]; i += 1
                row.setValue(Int32(c.id), forKey: "id")
                row.setValue(c.name,       forKey: "name")
                row.setValue(c.country,    forKey: "country")
                row.setValue(c.coord.lat,  forKey: "latitude")
                row.setValue(c.coord.lon,  forKey: "longitude")
                row.setValue(TextNormalizer.fold(c.name), forKey: "nameFolded")
                return false
            }
            try ctx.execute(insert)

            if ctx.hasChanges { try ctx.save() }
        }
    }
}

extension NSManagedObjectContext {
    func performAsync<T>(_ work: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<T, Error>) in
            self.perform {
                do { cont.resume(returning: try work(self)) }
                catch { cont.resume(throwing: error) }
            }
        }
    }
}
