import Foundation
import CoreData
@testable import SmartCity

final class MockCoreDataStack: CoreDataStackProtocol {
    
    var saveCitiesCallCount = 0
    var lastSavedCities: CitiesResponse?
    var mockError: Error?
    var shouldThrowError = false
    
    private lazy var mockPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SmartCityData")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load mock store: \(error)")
            }
        }
        
        return container
    }()
    
    var persistentContainer: NSPersistentContainer {
        get throws {
            return mockPersistentContainer
        }
    }
    
    var context: NSManagedObjectContext {
        get throws {
            return mockPersistentContainer.viewContext
        }
    }
    
    func saveContext() throws {
        if shouldThrowError, let mockError = mockError {
            throw mockError
        }
    }
    
    func saveCities(_ cities: CitiesResponse) async throws {
        saveCitiesCallCount += 1
        lastSavedCities = cities
        
        if shouldThrowError, let mockError = mockError {
            throw mockError
        }
    }
    
    func reset() {
        saveCitiesCallCount = 0
        lastSavedCities = nil
        mockError = nil
        shouldThrowError = false
    }
    
    func setMockError(_ error: Error) {
        mockError = error
        shouldThrowError = true
    }
    
    func setSuccess() {
        mockError = nil
        shouldThrowError = false
    }
}