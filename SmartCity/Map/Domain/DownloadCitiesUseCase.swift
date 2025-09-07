//
//  DownloadCitiesUseCase.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 06/09/2025.
//

import Foundation

protocol DownloadCitiesUseCaseProtocol {
    func executeIfNeeded() async throws
}

final class DownloadCitiesUseCase: DownloadCitiesUseCaseProtocol {
    
    private let repository: DownloadCitiesRepositoryProtocol
    
    init(
        repository: DownloadCitiesRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    func executeIfNeeded() async throws {
        //TODO: if needed
        _ = try await repository.fetchCities()
    }
}
