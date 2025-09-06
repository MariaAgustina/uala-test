//
//  CitiesDataSource.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation

protocol CitiesDataSourceProtocol {
    func fetchCities() async throws -> CitiesResponse
}

final class CitiesDataSource: CitiesDataSourceProtocol {
    
    func fetchCities() async throws -> CitiesResponse {
        guard let url = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let cities = try JSONDecoder().decode(CitiesResponse.self, from: data)
        return cities
    }
}