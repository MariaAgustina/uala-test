import XCTest
@testable import SmartCity

final class CityDetailViewModelTests: XCTestCase {
    
    var sut: CityDetailViewModel?
    
    override func setUp() {
        super.setUp()
        let testCity = CityResponse(
            country: "AR",
            name: "Buenos Aires",
            id: 1,
            coord: Coordinate(lon: -58.3816, lat: -34.6037)
        )
        sut = CityDetailViewModel(city: testCity)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialization() {
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        XCTAssertEqual(sut.city.name, "Buenos Aires")
        XCTAssertEqual(sut.city.country, "AR")
        XCTAssertEqual(sut.city.id, 1)
        XCTAssertEqual(sut.city.coord.lon, -58.3816)
        XCTAssertEqual(sut.city.coord.lat, -34.6037)
    }
    
    func testFormattedCoordinates() {
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let formatted = sut.formattedCoordinates
        
        XCTAssertEqual(formatted, "-34.6037, -58.3816")
    }
    
    func testCoordinateDescriptionSouthWest() {
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let description = sut.coordinateDescription
        
        XCTAssertEqual(description, "34.6037°S 58.3816°W")
    }
    
    func testCoordinateDescriptionNorthEast() {
        let northEastCity = CityResponse(
            country: "GB",
            name: "London",
            id: 2,
            coord: Coordinate(lon: 0.1278, lat: 51.5074)
        )
        sut = CityDetailViewModel(city: northEastCity)
        
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let description = sut.coordinateDescription
        
        XCTAssertEqual(description, "51.5074°N 0.1278°E")
    }
    
    func testCoordinateDescriptionSouthEast() {
        let southEastCity = CityResponse(
            country: "AU",
            name: "Sydney",
            id: 3,
            coord: Coordinate(lon: 151.2093, lat: -33.8688)
        )
        sut = CityDetailViewModel(city: southEastCity)
        
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let description = sut.coordinateDescription
        
        XCTAssertEqual(description, "33.8688°S 151.2093°E")
    }
    
    func testCoordinateDescriptionNorthWest() {
        let northWestCity = CityResponse(
            country: "US",
            name: "Seattle",
            id: 4,
            coord: Coordinate(lon: -122.3321, lat: 47.6062)
        )
        sut = CityDetailViewModel(city: northWestCity)
        
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let description = sut.coordinateDescription
        
        XCTAssertEqual(description, "47.6062°N 122.3321°W")
    }
    
    func testCoordinateDescriptionZeroCoordinates() {
        let zeroCity = CityResponse(
            country: "GH",
            name: "Null Island",
            id: 5,
            coord: Coordinate(lon: 0.0, lat: 0.0)
        )
        sut = CityDetailViewModel(city: zeroCity)
        
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let description = sut.coordinateDescription
        
        XCTAssertEqual(description, "0.0000°N 0.0000°E")
    }
    
    func testFormattedCoordinatesWithPrecision() {
        let preciseCity = CityResponse(
            country: "JP",
            name: "Tokyo",
            id: 6,
            coord: Coordinate(lon: 139.6917337, lat: 35.6895014)
        )
        sut = CityDetailViewModel(city: preciseCity)
        
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let formatted = sut.formattedCoordinates
        
        XCTAssertEqual(formatted, "35.6895, 139.6917")
    }
    
    func testFormattedCoordinatesNegativeValues() {
        let negativeCity = CityResponse(
            country: "CL",
            name: "Santiago",
            id: 7,
            coord: Coordinate(lon: -70.6693, lat: -33.4489)
        )
        sut = CityDetailViewModel(city: negativeCity)
        
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let formatted = sut.formattedCoordinates
        
        XCTAssertEqual(formatted, "-33.4489, -70.6693")
    }
    
    func testCoordinateDescriptionPrecision() {
        let preciseCity = CityResponse(
            country: "FR",
            name: "Paris",
            id: 8,
            coord: Coordinate(lon: 2.3522219, lat: 48.8566140)
        )
        sut = CityDetailViewModel(city: preciseCity)
        
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        let description = sut.coordinateDescription
        
        XCTAssertEqual(description, "48.8566°N 2.3522°E")
    }
    
    func testCityPropertyIsPublished() {
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        XCTAssertTrue(sut is ObservableObject)
        
        let newCity = CityResponse(
            country: "IT",
            name: "Rome",
            id: 9,
            coord: Coordinate(lon: 12.4964, lat: 41.9028)
        )
        
        sut.city = newCity
        
        XCTAssertEqual(sut.city.name, "Rome")
        XCTAssertEqual(sut.city.country, "IT")
        XCTAssertEqual(sut.city.id, 9)
    }
}