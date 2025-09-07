//
//  CityDetailViewModel.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 07/09/2025.
//

import Foundation

final class CityDetailViewModel: ObservableObject {
    
    @Published var city: CityResponse
    
    init(city: CityResponse) {
        self.city = city
    }
    
    var formattedCoordinates: String {
        return String(format: "%.4f, %.4f", city.coord.lat, city.coord.lon)
    }
    
    var coordinateDescription: String {
        let latDirection = city.coord.lat >= 0 ? "N" : "S"
        let lonDirection = city.coord.lon >= 0 ? "E" : "W"
        
        let latValue = abs(city.coord.lat)
        let lonValue = abs(city.coord.lon)
        
        return String(format: "%.4f°%@ %.4f°%@", latValue, latDirection, lonValue, lonDirection)
    }
}