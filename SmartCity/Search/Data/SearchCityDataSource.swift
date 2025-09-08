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
            
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedQuery.isEmpty else { return [] }
            
            let parts = trimmedQuery.split(separator: ",", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
            let cityPrefix = TextNormalizer.fold(parts.first ?? "")
            let countryPrefix = parts.count > 1 ? parts[1].uppercased() : nil
            
            var predicates: [NSPredicate] = []
            
            let lo = cityPrefix
            let hi = TextNormalizer.upperBoundForPrefix(lo)
            predicates.append(NSPredicate(format: "nameFolded >= %@", lo))
            predicates.append(NSPredicate(format: "nameFolded < %@", hi))
            
            if let countryPrefix = countryPrefix, !countryPrefix.isEmpty {
                predicates.append(NSPredicate(format: "country BEGINSWITH[c] %@", countryPrefix))
            }
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [
                NSSortDescriptor(key: "nameFolded", ascending: true),
                NSSortDescriptor(key: "country", ascending: true)
            ]
            request.fetchLimit = 20
            
            let cities = try ctx.fetch(request)
            
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
