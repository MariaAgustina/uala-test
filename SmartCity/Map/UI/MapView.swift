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
    
    //TODO: hardcoded, this should be obteined from location services
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @State private var detent: PresentationDetent = MapView.customShortDetent
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapScaleView()
        }
        .sheet(isPresented: .constant(true)) {
            SearchView(detent: $detent)
                .presentationDetents([MapView.customShortDetent, .large], selection: $detent)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: detent))
        }
    }
}

#Preview {
    MapView()
}
