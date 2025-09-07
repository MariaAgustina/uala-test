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
    
    private let coreDataStack: CoreDataStackProtocol
    
    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }
    
    func searchCities(query: String) async throws -> [CityResponse] {
        let backgroundContext = coreDataStack.newBackgroundContext()
        
        return try await backgroundContext.performAsync { ctx in
            let request: NSFetchRequest<City> = City.fetchRequest()
            
            request.predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", query)
            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true),
                NSSortDescriptor(key: "country", ascending: true)
            ]
            request.fetchLimit = 20
            
            let cities = try ctx.fetch(request)
            print("🔍 CoreData query: '\(query)' -> \(cities.count) results")
            
            return cities.map { city in
                CityResponse(
                    country: city.country ?? "",
                    name: city.name ?? "",
                    id: Int(city.id),
                    coord: Coordinate(lon: city.longitude, lat: city.latitude)
                )
            }
        }
    }
}
