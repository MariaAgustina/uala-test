//
//  MapView.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import SwiftUI
import MapKit

struct MapView: View {

    static let customShortDetent: PresentationDetent = .height(100)
    
    @StateObject private var viewModel = MapViewModel()
    
    //TODO: hardcoded, this should be obteined from location services
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @State private var detent: PresentationDetent = MapView.customShortDetent
    @State private var selectedCity: CityResponse?
    @State private var showingSearch = true
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapScaleView()
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(
                detent: $detent, 
                collapsedDetent: MapView.customShortDetent
            ) { city in
                navigateToCity(city)
                selectedCity = city
                showingSearch = false
            }
                .presentationDetents([MapView.customShortDetent, .large], selection: $detent)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: detent))
        }
        .sheet(item: $selectedCity, onDismiss: {
            showingSearch = true
        }) { city in
            CityDetailView(city: city) {
                selectedCity = nil
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            Task {
                do {
                    try await CoreDataStack.shared.load()
                    await viewModel.fetchDataIfNeeded()
                } catch {
                    print("❌ Failed to load CoreData: \(error)")
                }
            }
        }
        .onChange(of: showingSearch) { oldValue, newValue in
            if newValue {
                detent = MapView.customShortDetent
            }
        }
    }
    
    private func navigateToCity(_ city: CityResponse) {
        withAnimation(.easeInOut(duration: 1.0)) {
            position = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: city.coord.lat, 
                        longitude: city.coord.lon
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        }
    }
}

#Preview {
    MapView()
}
