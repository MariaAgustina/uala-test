//
//  SearchCityViewModel.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation
import Combine

final class SearchCityViewModel: ObservableObject {
    
    @Published var searchResults: [CityResponse] = []
    @Published var isSearching = false
    @Published var searchQuery = ""
    
    private let searchCityUseCase: SearchCityUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(searchCityUseCase: SearchCityUseCaseProtocol = SearchCityUseCase()) {
        self.searchCityUseCase = searchCityUseCase
        setupSearchPipeline()
    }
    
    private func setupSearchPipeline() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        Task { @MainActor in
            do {
                let results = try await searchCityUseCase.execute(query: query)
                searchResults = results
                isSearching = false
                print("🔍 Found \(results.count) cities for query: '\(query)'")
                print("📝 City names: \(results.map { $0.name }.joined(separator: ", "))")
            } catch {
                searchResults = []
                isSearching = false
                print("❌ Error searching cities: \(error)")
            }
        }
    }
}
