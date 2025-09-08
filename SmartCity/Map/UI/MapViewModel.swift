//
//  MapViewModel.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 06/09/2025.
//

import Foundation

final class MapViewModel: ObservableObject {
    
    private let downloadCitiesUseCase: DownloadCitiesUseCaseProtocol
    
    init(
        downloadCitiesUseCase: DownloadCitiesUseCaseProtocol
    ) {
        self.downloadCitiesUseCase = downloadCitiesUseCase
    }
    

    func fetchDataIfNeeded() async {
        do {
            try await downloadCitiesUseCase.executeIfNeeded()
        } catch {
            //TODO: log error
        }
    }
    
}
