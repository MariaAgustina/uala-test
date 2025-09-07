import XCTest
@testable import SmartCity

final class SearchCityRepositoryTests: XCTestCase {
    
    var sut: SearchCityRepository?
    var mockDataSource: MockSearchCityDataSource?
    
    override func setUp() {
        super.setUp()
        mockDataSource = MockSearchCityDataSource()
        sut = SearchCityRepository(dataSource: mockDataSource!)
    }
    
    override func tearDown() {
        mockDataSource?.reset()
        sut = nil
        mockDataSource = nil
        super.tearDown()
    }
    
    func testSearchCitiesSuccess() async throws {
        guard let sut = sut,
              let mockDataSource = mockDataSource else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037)),
            CityResponse(country: "AR", name: "Bucaramanga", id: 2, coord: Coordinate(lon: -73.1198, lat: 7.1193))
        ]
        mockDataSource.setMockResults(expectedCities)
        
        let results = try await sut.searchCities(query: "Bu")
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.name, "Buenos Aires")
        XCTAssertEqual(mockDataSource.searchCallCount, 1)
        XCTAssertEqual(mockDataSource.lastQuery, "Bu")
    }
    
    func testSearchCitiesError() async {
        guard let sut = sut,
              let mockDataSource = mockDataSource else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        enum TestError: Error { case dataSourceError }
        mockDataSource.setMockError(TestError.dataSourceError)
        
        do {
            _ = try await sut.searchCities(query: "Test")
            XCTFail("Expected error was not thrown")
        } catch {
            XCTAssertEqual(mockDataSource.searchCallCount, 1)
            XCTAssertEqual(mockDataSource.lastQuery, "Test")
        }
    }
    
    func testSearchCitiesEmpty() async throws {
        guard let sut = sut,
              let mockDataSource = mockDataSource else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockDataSource.setMockResults([])
        
        let results = try await sut.searchCities(query: "NonExistent")
        
        XCTAssertEqual(results, [])
        XCTAssertEqual(mockDataSource.searchCallCount, 1)
        XCTAssertEqual(mockDataSource.lastQuery, "NonExistent")
    }
    
    func testSearchCitiesMultipleCalls() async throws {
        guard let sut = sut,
              let mockDataSource = mockDataSource else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        mockDataSource.setMockResults(expectedCities)
        
        _ = try await sut.searchCities(query: "First")
        _ = try await sut.searchCities(query: "Second")
        _ = try await sut.searchCities(query: "Third")
        
        XCTAssertEqual(mockDataSource.searchCallCount, 3)
        XCTAssertEqual(mockDataSource.lastQuery, "Third")
    }
    
    func testSearchCitiesWithDifferentQueries() async throws {
        guard let sut = sut,
              let mockDataSource = mockDataSource else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let buenosAiresCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        
        mockDataSource.setMockResults(buenosAiresCities)
        let firstResults = try await sut.searchCities(query: "Buenos")
        
        let saoPauloCities = [
            CityResponse(country: "BR", name: "São Paulo", id: 2, coord: Coordinate(lon: -46.6333, lat: -23.5505))
        ]
        
        mockDataSource.setMockResults(saoPauloCities)
        let secondResults = try await sut.searchCities(query: "São")
        
        XCTAssertEqual(firstResults.first?.name, "Buenos Aires")
        XCTAssertEqual(secondResults.first?.name, "São Paulo")
        XCTAssertEqual(mockDataSource.searchCallCount, 2)
    }
}