//
//  SmartCity.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 06/09/2025.
//

@testable import SmartCity

extension CityResponse: Equatable {
    public static func == (lhs: CityResponse, rhs: CityResponse) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.country == rhs.country &&
               lhs.coord.lat == rhs.coord.lat &&
               lhs.coord.lon == rhs.coord.lon
    }
}

extension Coordinate: Equatable {
    public static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.lat == rhs.lat && lhs.lon == rhs.lon
    }
}
