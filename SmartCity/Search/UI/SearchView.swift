//
//  SearchView.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import SwiftUI

struct SearchView: View {
    
    @ObservedObject var viewModel: SearchCityViewModel
    @FocusState private var isSearchFocused: Bool
    
    @Binding var detent: PresentationDetent
    private let collapsedDetent: PresentationDetent
    let onCitySelected: (CityResponse) -> Void
    
    init(
        viewModel: SearchCityViewModel,
        detent: Binding<PresentationDetent>,
        collapsedDetent: PresentationDetent = .height(100),
        onCitySelected: @escaping (CityResponse) -> Void
    ) {
        self.viewModel = viewModel
        self._detent = detent
        self.collapsedDetent = collapsedDetent
        self.onCitySelected = onCitySelected
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                //TODO: localization
                TextField("Buscar ciudad...", text: $viewModel.searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isSearchFocused)
                    .accessibilityIdentifier("search_text_field")
                    .onChange(of: isSearchFocused) { oldValue, newValue in
                        if newValue {
                            withAnimation {
                                detent = .large
                            }
                        } else {
                            withAnimation {
                                detent = collapsedDetent
                                viewModel.searchQuery = ""
                            }
                        }
                    }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                        isSearchFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if viewModel.isSearching {
                //TODO: localization
                ProgressView("Buscando...")
                    .padding()
                Spacer()
            } else if !viewModel.searchResults.isEmpty {
                List(Array(viewModel.searchResults.enumerated()), id: \.offset) { index, city in
                    Button(action: {
                        onCitySelected(city)
                        isSearchFocused = false
                        withAnimation {
                            detent = collapsedDetent
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(city.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(city.country)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(PlainListStyle())
                .accessibilityIdentifier("search_results_list")
            } else if !viewModel.searchQuery.isEmpty {
                //TODO: localization
                Text("No se encontraron ciudades")
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                Spacer()
            }
        }
        .padding()
        .background(Color.clear)
    }
}

#Preview {
    let coreDataStack = CoreDataStack()
    let searchDataSource = SearchCityDataSource(coreDataStack: coreDataStack)
    let searchRepo = SearchCityRepository(dataSource: searchDataSource)
    let searchUseCase = SearchCityUseCase(repository: searchRepo)
    let searchViewModel = SearchCityViewModel(searchCityUseCase: searchUseCase)
    
    return SearchView(
        viewModel: searchViewModel,
        detent: .constant(.height(200))
    ) { city in
        print("Selected: \(city.name)")
    }
}
