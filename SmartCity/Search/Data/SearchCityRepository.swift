//
//  SearchCityRepository.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation

protocol SearchCityRepositoryProtocol {
    func searchCities(query: String) async throws -> [CityResponse]
}

final class SearchCityRepository: SearchCityRepositoryProtocol {
    
    private let dataSource: SearchCityDataSourceProtocol
    
    init(dataSource: SearchCityDataSourceProtocol = SearchCityDataSource(coreDataStack: CoreDataStack.shared)) {
        self.dataSource = dataSource
    }
    
    func searchCities(query: String) async throws -> [CityResponse] {
        return try await dataSource.searchCities(query: query)
    }
}