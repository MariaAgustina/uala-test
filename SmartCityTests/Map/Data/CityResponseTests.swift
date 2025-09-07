import XCTest
@testable import SmartCity

final class CityResponseTests: XCTestCase {
    
    func testCityResponseInitialization() {
        let coordinate = Coordinate(lon: -58.3816, lat: -34.6037)
        let cityResponse = CityResponse(
            country: "AR",
            name: "Buenos Aires",
            id: 1,
            coord: coordinate
        )
        
        XCTAssertEqual(cityResponse.country, "AR")
        XCTAssertEqual(cityResponse.name, "Buenos Aires")
        XCTAssertEqual(cityResponse.id, 1)
        XCTAssertEqual(cityResponse.coord.lon, -58.3816)
        XCTAssertEqual(cityResponse.coord.lat, -34.6037)
    }
    
    func testCoordinateInitialization() {
        let coordinate = Coordinate(lon: 2.1734, lat: 41.3851)
        
        XCTAssertEqual(coordinate.lon, 2.1734)
        XCTAssertEqual(coordinate.lat, 41.3851)
    }
    
    func testCityResponseJSONDecoding() throws {
        let json = """
        {
            "country": "ES",
            "name": "Barcelona",
            "_id": 12345,
            "coord": {
                "lon": 2.1734,
                "lat": 41.3851
            }
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        let cityResponse = try JSONDecoder().decode(CityResponse.self, from: jsonData)
        
        XCTAssertEqual(cityResponse.country, "ES")
        XCTAssertEqual(cityResponse.name, "Barcelona")
        XCTAssertEqual(cityResponse.id, 12345)
        XCTAssertEqual(cityResponse.coord.lon, 2.1734)
        XCTAssertEqual(cityResponse.coord.lat, 41.3851)
    }
    
    func testCitiesResponseArrayDecoding() throws {
        let json = """
        [
            {
                "country": "AR",
                "name": "Buenos Aires",
                "_id": 1,
                "coord": {
                    "lon": -58.3816,
                    "lat": -34.6037
                }
            },
            {
                "country": "BR",
                "name": "São Paulo",
                "_id": 2,
                "coord": {
                    "lon": -46.6333,
                    "lat": -23.5505
                }
            }
        ]
        """
        
        let jsonData = json.data(using: .utf8)!
        let citiesResponse = try JSONDecoder().decode(CitiesResponse.self, from: jsonData)
        
        XCTAssertEqual(citiesResponse.count, 2)
        
        XCTAssertEqual(citiesResponse[0].name, "Buenos Aires")
        XCTAssertEqual(citiesResponse[0].country, "AR")
        XCTAssertEqual(citiesResponse[0].id, 1)
        
        XCTAssertEqual(citiesResponse[1].name, "São Paulo")
        XCTAssertEqual(citiesResponse[1].country, "BR")
        XCTAssertEqual(citiesResponse[1].id, 2)
    }
    
    func testCityResponseJSONEncoding() throws {
        let coordinate = Coordinate(lon: -73.1198, lat: 7.1193)
        let cityResponse = CityResponse(
            country: "CO",
            name: "Bucaramanga",
            id: 999,
            coord: coordinate
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        let jsonData = try encoder.encode(cityResponse)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        XCTAssertTrue(jsonString.contains("\"country\":\"CO\""))
        XCTAssertTrue(jsonString.contains("\"name\":\"Bucaramanga\""))
        XCTAssertTrue(jsonString.contains("\"_id\":999"))
        XCTAssertTrue(jsonString.contains("\"coord\":{"))
        XCTAssertTrue(jsonString.contains("\"lat\":7.1193"))
        XCTAssertTrue(jsonString.contains("\"lon\":-73.1198"))
    }
    
    func testCityResponseEquality() {
        let coord1 = Coordinate(lon: -58.3816, lat: -34.6037)
        let coord2 = Coordinate(lon: -58.3816, lat: -34.6037)
        let coord3 = Coordinate(lon: 2.1734, lat: 41.3851)
        
        let city1 = CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: coord1)
        let city2 = CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: coord2)
        let city3 = CityResponse(country: "ES", name: "Barcelona", id: 2, coord: coord3)
        
        XCTAssertEqual(city1, city2)
        XCTAssertNotEqual(city1, city3)
        XCTAssertEqual(coord1, coord2)
        XCTAssertNotEqual(coord1, coord3)
    }
    
    func testCoordinateEquality() {
        let coord1 = Coordinate(lon: -58.3816, lat: -34.6037)
        let coord2 = Coordinate(lon: -58.3816, lat: -34.6037)
        let coord3 = Coordinate(lon: -58.3817, lat: -34.6037)
        let coord4 = Coordinate(lon: -58.3816, lat: -34.6038)
        
        XCTAssertEqual(coord1, coord2)
        XCTAssertNotEqual(coord1, coord3)
        XCTAssertNotEqual(coord1, coord4)
    }
    
    func testInvalidJSONDecoding() {
        let invalidJson = """
        {
            "country": "AR",
            "name": "Buenos Aires"
        }
        """
        
        let jsonData = invalidJson.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(CityResponse.self, from: jsonData)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testEmptyArrayDecoding() throws {
        let emptyJson = "[]"
        let jsonData = emptyJson.data(using: .utf8)!
        let citiesResponse = try JSONDecoder().decode(CitiesResponse.self, from: jsonData)
        
        XCTAssertEqual(citiesResponse.count, 0)
        XCTAssertTrue(citiesResponse.isEmpty)
    }
    
    func testCoordinateWithZeroValues() {
        let coord = Coordinate(lon: 0.0, lat: 0.0)
        
        XCTAssertEqual(coord.lon, 0.0)
        XCTAssertEqual(coord.lat, 0.0)
    }
    
    func testCoordinateWithNegativeValues() {
        let coord = Coordinate(lon: -180.0, lat: -90.0)
        
        XCTAssertEqual(coord.lon, -180.0)
        XCTAssertEqual(coord.lat, -90.0)
    }
}