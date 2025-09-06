//
//  CityModel.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation

typealias CitiesResponse = [CityResponse]

struct CityResponse: Codable {
    let country: String
    let name: String
    let id: Int
    let coord: Coordinate
    
    enum CodingKeys: String, CodingKey {
        case country, name
        case id = "_id"
        case coord
    }
}

struct Coordinate: Codable {
    let lon: Double
    let lat: Double
}