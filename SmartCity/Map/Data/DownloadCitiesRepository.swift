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
        dataSource: CitiesDataSourceProtocol,
        coreDataStack: CoreDataStackProtocol
    ) {
        self.dataSource = dataSource
        self.coreDataStack = coreDataStack
    }
    
    func fetchCities() async throws -> CitiesResponse {
        let cities = try await dataSource.fetchCities()
        
        do {
            try await coreDataStack.saveCities(cities)
        } catch {
            throw error
        }
        
        return cities
    }
}
