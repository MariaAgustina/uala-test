//
//  SearchView.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import SwiftUI

struct SearchView: View {
    
    @StateObject private var viewModel = SearchCityViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Binding var detent: PresentationDetent
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                //TODO: localization
                TextField("Buscar ciudad...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isSearchFocused)
                    .onChange(of: searchText) { oldValue, newValue in
                        viewModel.searchCities(query: newValue)
                    }
                    .onChange(of: isSearchFocused) { oldValue, newValue in
                        if newValue {
                            withAnimation {
                                detent = .large
                            }
                        } else {
                            withAnimation {
                                detent = MapView.customShortDetent
                                searchText = ""
                            }
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(city.name)
                            .font(.headline)
                        Text(city.country)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(PlainListStyle())
            } else if !searchText.isEmpty {
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
    SearchView(detent: .constant(.height(200)))
}
