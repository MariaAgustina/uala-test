import XCTest
@testable import SmartCity

final class SearchCityUseCaseTests: XCTestCase {
    
    var sut: SearchCityUseCase?
    var mockRepository: MockSearchCityRepository?
    
    override func setUp() {
        super.setUp()
        mockRepository = MockSearchCityRepository()
        sut = SearchCityUseCase(repository: mockRepository!)
    }
    
    override func tearDown() {
        mockRepository?.reset()
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testExecuteWithValidQuery() async throws {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037)),
            CityResponse(country: "AR", name: "Bucaramanga", id: 2, coord: Coordinate(lon: -73.1198, lat: 7.1193))
        ]
        mockRepository.setMockResults(expectedCities)
        
        let results = try await sut.execute(query: "Bu")
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.name, "Buenos Aires")
        XCTAssertEqual(mockRepository.searchCallCount, 1)
        XCTAssertEqual(mockRepository.lastQuery, "Bu")
    }
    
    func testExecuteWithEmptyQuery() async throws {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setMockResults([CityResponse(country: "AR", name: "Test", id: 1, coord: Coordinate(lon: 0, lat: 0))])
        
        let results = try await sut.execute(query: "")
        
        XCTAssertEqual(results, [])
        XCTAssertEqual(mockRepository.searchCallCount, 0)
    }
    
    func testExecuteWithWhitespaceQuery() async throws {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setMockResults([CityResponse(country: "AR", name: "Test", id: 1, coord: Coordinate(lon: 0, lat: 0))])
        
        let results = try await sut.execute(query: "   ")
        
        XCTAssertEqual(results, [])
        XCTAssertEqual(mockRepository.searchCallCount, 0)
    }
    
    func testExecuteWithRepositoryError() async {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        enum TestError: Error { case networkError }
        mockRepository.setMockError(TestError.networkError)
        
        do {
            _ = try await sut.execute(query: "Test")
            XCTFail("Expected error was not thrown")
        } catch {
            XCTAssertEqual(mockRepository.searchCallCount, 1)
            XCTAssertEqual(mockRepository.lastQuery, "Test")
        }
    }
    
    func testExecuteWithQueryTrimming() async throws {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        mockRepository.setMockResults(expectedCities)
        
        let results = try await sut.execute(query: "  Buenos  ")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(mockRepository.searchCallCount, 1)
        XCTAssertEqual(mockRepository.lastQuery, "  Buenos  ")
    }
    
    func testExecuteWithNoResults() async throws {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setMockResults([])
        
        let results = try await sut.execute(query: "NonExistentCity")
        
        XCTAssertEqual(results, [])
        XCTAssertEqual(mockRepository.searchCallCount, 1)
        XCTAssertEqual(mockRepository.lastQuery, "NonExistentCity")
    }
}