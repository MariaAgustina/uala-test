//
//  CityDetailView.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 07/09/2025.
//

import SwiftUI

struct CityDetailView: View {
    
    @StateObject private var viewModel: CityDetailViewModel
    let onClose: () -> Void
    
    init(city: CityResponse, onClose: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: CityDetailViewModel(city: city))
        self.onClose = onClose
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 20) {
                    cityInfoCard
                    locationInfoCard
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .accessibilityIdentifier("city_detail_view")
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.city.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(viewModel.city.country)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var cityInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Información de la Ciudad")
                    .font(.headline)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                infoRow(title: "Nombre", value: viewModel.city.name, icon: "building.2")
                infoRow(title: "País", value: viewModel.city.country, icon: "flag")
                infoRow(title: "ID", value: String(viewModel.city.id), icon: "number")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var locationInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "globe")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Ubicación Geográfica")
                    .font(.headline)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                infoRow(
                    title: "Latitud", 
                    value: String(format: "%.6f°", viewModel.city.coord.lat), 
                    icon: "location.north"
                )
                infoRow(
                    title: "Longitud", 
                    value: String(format: "%.6f°", viewModel.city.coord.lon), 
                    icon: "location"
                )
                infoRow(
                    title: "Coordenadas", 
                    value: viewModel.coordinateDescription, 
                    icon: "mappin.and.ellipse"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.secondary)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CityDetailView(
        city: CityResponse(
            country: "AR",
            name: "Buenos Aires",
            id: 1,
            coord: Coordinate(lon: -58.3816, lat: -34.6037)
        )
    ) {
        print("Close tapped")
    }
}
