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
    private var currentTask: Task<Void, Never>?
    private var loadingTask: Task<Void, Never>?
    
    init(searchCityUseCase: SearchCityUseCaseProtocol) {
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
        currentTask?.cancel()
        loadingTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        loadingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms for ux purpose
            guard !Task.isCancelled else { return }
            isSearching = true
        }
        
        currentTask = Task { @MainActor in
            do {
                let results = try await searchCityUseCase.execute(query: query)
                guard !Task.isCancelled else { return }
                
                loadingTask?.cancel()
                searchResults = results
                isSearching = false
            } catch {
                guard !Task.isCancelled else { return }
                
                loadingTask?.cancel()
                searchResults = []
                isSearching = false
            }
        }
    }
}
