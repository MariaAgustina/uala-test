//
//  SearchCityViewModel.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation

final class SearchCityViewModel: ObservableObject {
    
    @Published var searchResults: [CityResponse] = []
    @Published var isSearching = false
    
    private let searchCityUseCase: SearchCityUseCaseProtocol
    private var searchTask: Task<Void, Never>?
    
    init(searchCityUseCase: SearchCityUseCaseProtocol = SearchCityUseCase()) {
        self.searchCityUseCase = searchCityUseCase
    }
    
    func searchCities(query: String) {
        // Cancelar búsqueda anterior
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        searchTask = Task { @MainActor in
            
            //TODO: review this!!!
            // Debounce de 500ms para evitar crashes de Metal
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { 
                isSearching = false
                return 
            }
            
            do {
                let results = try await searchCityUseCase.execute(query: query)
                
                guard !Task.isCancelled else { 
                    isSearching = false
                    return 
                }
                
                searchResults = results
                isSearching = false
                print("🔍 Found \(results.count) cities for query: '\(query)'")
                print("📝 City names: \(results.map { $0.name }.joined(separator: ", "))")
            } catch {
                guard !Task.isCancelled else { return }
                
                searchResults = []
                isSearching = false
                print("❌ Error searching cities: \(error)")
            }
        }
    }
}
