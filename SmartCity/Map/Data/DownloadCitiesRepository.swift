//
//  DownloadCitiesRepository.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 06/09/2025.
//

import Foundation

protocol DownloadCitiesRepositoryProtocol {
    func fetchCities() async throws -> CitiesResponse
}

final class DownloadCitiesRepository: DownloadCitiesRepositoryProtocol {
    
    private let dataSource: CitiesDataSourceProtocol
    private let coreDataStack: CoreDataStackProtocol
    
    init(
        dataSource: CitiesDataSourceProtocol = CitiesDataSource(),
        coreDataStack: CoreDataStackProtocol
    ) {
        self.dataSource = dataSource
        self.coreDataStack = coreDataStack
    }
    
    func fetchCities() async throws -> CitiesResponse {
        print("🌍 Starting cities download...")
        let cities = try await dataSource.fetchCities()
        print("📱 Downloaded \(cities.count) cities from API")
        
        do {
            try await coreDataStack.saveCities(cities)
            print("💾 Cities saved to CoreData successfully")
        } catch {
            print("❌ Failed to save cities to CoreData: \(error)")
            throw error
        }
        
        return cities
    }
}
