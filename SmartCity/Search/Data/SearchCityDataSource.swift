//
//  SearchCityDataSource.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation
import CoreData

protocol SearchCityDataSourceProtocol {
    func searchCities(query: String) async throws -> [CityResponse]
}

final class SearchCityDataSource: SearchCityDataSourceProtocol {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func searchCities(query: String) async throws -> [CityResponse] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let backgroundContext = try coreDataStack.persistentContainer.newBackgroundContext()
                
                backgroundContext.perform {
                    let request: NSFetchRequest<City> = City.fetchRequest()
                    
                    request.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", query)
                    request.sortDescriptors = [
                        NSSortDescriptor(key: "name", ascending: true),
                        NSSortDescriptor(key: "country", ascending: true)
                    ]
                    request.fetchLimit = 20
                    
                    do {
                        let cities = try backgroundContext.fetch(request)
                        print("🔍 CoreData query: '\(query)' -> \(cities.count) results")
                        
                        // Convertir a CityResponse aquí para ser thread-safe
                        let cityResponses = cities.map { city in
                            CityResponse(
                                country: city.country ?? "",
                                name: city.name ?? "",
                                id: Int(city.id),
                                coord: Coordinate(lon: city.longitude, lat: city.latitude)
                            )
                        }
                        
                        continuation.resume(returning: cityResponses)
                    } catch {
                        print("❌ Error searching cities: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            } catch {
                print("❌ Error creating CoreData context: \(error)")
                continuation.resume(throwing: error)
            }
        }
    }
}
