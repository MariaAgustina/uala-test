import XCTest
@testable import SmartCity

final class DownloadCitiesRepositoryTests: XCTestCase {
    
    var sut: DownloadCitiesRepository?
    var mockDataSource: MockCitiesDataSource?
    var mockCoreDataStack: MockCoreDataStack?
    
    override func setUp() {
        super.setUp()
        mockDataSource = MockCitiesDataSource()
        mockCoreDataStack = MockCoreDataStack()
        sut = DownloadCitiesRepository(dataSource: mockDataSource!, coreDataStack: mockCoreDataStack!)
    }
    
    override func tearDown() {
        mockDataSource?.reset()
        mockCoreDataStack?.reset()
        sut = nil
        mockDataSource = nil
        mockCoreDataStack = nil
        super.tearDown()
    }
    
    func testFetchCitiesSuccess() async throws {
        guard let sut = sut,
              let mockDataSource = mockDataSource,
              let mockCoreDataStack = mockCoreDataStack else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037)),
            CityResponse(country: "BR", name: "São Paulo", id: 2, coord: Coordinate(lon: -46.6333, lat: -23.5505))
        ]
        mockDataSource.setMockResult(expectedCities)
        mockCoreDataStack.setSuccess()
        
        let result = try await sut.fetchCities()
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.name, "Buenos Aires")
        XCTAssertEqual(mockDataSource.fetchCallCount, 1)
        XCTAssertEqual(mockCoreDataStack.saveCitiesCallCount, 1)
        XCTAssertEqual(mockCoreDataStack.lastSavedCities?.count, 2)
    }
    
    func testFetchCitiesDataSourceError() async {
        guard let sut = sut,
              let mockDataSource = mockDataSource,
              let mockCoreDataStack = mockCoreDataStack else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        enum TestError: Error { case networkError }
        mockDataSource.setMockError(TestError.networkError)
        mockCoreDataStack.setSuccess()
        
        do {
            _ = try await sut.fetchCities()
            XCTFail("Expected error was not thrown")
        } catch {
            XCTAssertEqual(mockDataSource.fetchCallCount, 1)
            XCTAssertEqual(mockCoreDataStack.saveCitiesCallCount, 0)
        }
    }
    
    func testFetchCitiesCoreDataError() async {
        guard let sut = sut,
              let mockDataSource = mockDataSource,
              let mockCoreDataStack = mockCoreDataStack else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        mockDataSource.setMockResult(expectedCities)
        
        enum TestError: Error { case coreDataError }
        mockCoreDataStack.setMockError(TestError.coreDataError)
        
        do {
            _ = try await sut.fetchCities()
            XCTFail("Expected error was not thrown")
        } catch {
            XCTAssertEqual(mockDataSource.fetchCallCount, 1)
            XCTAssertEqual(mockCoreDataStack.saveCitiesCallCount, 1)
        }
    }
    
    func testFetchCitiesEmptyResult() async throws {
        guard let sut = sut,
              let mockDataSource = mockDataSource,
              let mockCoreDataStack = mockCoreDataStack else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockDataSource.setMockResult([])
        mockCoreDataStack.setSuccess()
        
        let result = try await sut.fetchCities()
        
        XCTAssertEqual(result, [])
        XCTAssertEqual(mockDataSource.fetchCallCount, 1)
        XCTAssertEqual(mockCoreDataStack.saveCitiesCallCount, 1)
        XCTAssertEqual(mockCoreDataStack.lastSavedCities, [])
    }
    
    func testFetchCitiesMultipleCalls() async throws {
        guard let sut = sut,
              let mockDataSource = mockDataSource,
              let mockCoreDataStack = mockCoreDataStack else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        mockDataSource.setMockResult(expectedCities)
        mockCoreDataStack.setSuccess()
        
        _ = try await sut.fetchCities()
        _ = try await sut.fetchCities()
        _ = try await sut.fetchCities()
        
        XCTAssertEqual(mockDataSource.fetchCallCount, 3)
        XCTAssertEqual(mockCoreDataStack.saveCitiesCallCount, 3)
    }
}