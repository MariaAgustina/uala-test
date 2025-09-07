import XCTest
@testable import SmartCity

final class DownloadCitiesUseCaseTests: XCTestCase {
    
    var sut: DownloadCitiesUseCase?
    var mockRepository: MockDownloadCitiesRepository?
    
    override func setUp() {
        super.setUp()
        mockRepository = MockDownloadCitiesRepository()
        sut = DownloadCitiesUseCase(repository: mockRepository!)
    }
    
    override func tearDown() {
        mockRepository?.reset()
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testExecuteIfNeededSuccess() async throws {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037)),
            CityResponse(country: "BR", name: "São Paulo", id: 2, coord: Coordinate(lon: -46.6333, lat: -23.5505))
        ]
        mockRepository.setMockResult(expectedCities)
        
        try await sut.executeIfNeeded()
        
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
        XCTAssertFalse(mockRepository.shouldThrowError)
    }
    
    func testExecuteIfNeededError() async {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        enum TestError: Error { case networkError }
        mockRepository.setMockError(TestError.networkError)
        
        do {
            try await sut.executeIfNeeded()
            XCTFail("Expected error was not thrown")
        } catch {
            XCTAssertEqual(mockRepository.fetchCallCount, 1)
            XCTAssertTrue(mockRepository.shouldThrowError)
        }
    }
    
    func testExecuteIfNeededWithEmptyResult() async throws {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setMockResult([])
        
        try await sut.executeIfNeeded()
        
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
        XCTAssertEqual(mockRepository.mockResult, [])
    }
    
    func testMultipleExecuteIfNeededCalls() async throws {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        mockRepository.setMockResult(expectedCities)
        
        try await sut.executeIfNeeded()
        try await sut.executeIfNeeded()
        try await sut.executeIfNeeded()
        
        XCTAssertEqual(mockRepository.fetchCallCount, 3)
    }
    
    func testExecuteIfNeededWithDifferentErrors() async {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        enum CustomError: Error { case customError }
        mockRepository.setMockError(CustomError.customError)
        
        do {
            try await sut.executeIfNeeded()
            XCTFail("Expected error was not thrown")
        } catch {
            XCTAssertEqual(mockRepository.fetchCallCount, 1)
            XCTAssertEqual(mockRepository.mockError as? CustomError, CustomError.customError)
        }
    }
}