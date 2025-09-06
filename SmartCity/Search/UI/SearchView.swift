//
//  SearchView.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import SwiftUI

struct SearchView: View {
    
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
            
            if !searchText.isEmpty {
                List {
                    Text("Resultado de búsqueda para '\(searchText)'")
                    Text("Ciudad ejemplo 1")
                    Text("Ciudad ejemplo 2")
                    Text("Ciudad ejemplo 3")
                }
                .listStyle(PlainListStyle())
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
