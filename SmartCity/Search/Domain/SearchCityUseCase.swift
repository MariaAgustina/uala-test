//
//  SearchCityUseCase.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation

protocol SearchCityUseCaseProtocol {
    func execute(query: String) async throws -> [CityResponse]
}

final class SearchCityUseCase: SearchCityUseCaseProtocol {
    
    private let repository: SearchCityRepositoryProtocol
    
    init(repository: SearchCityRepositoryProtocol = SearchCityRepository()) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> [CityResponse] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        return try await repository.searchCities(query: query)
    }
}