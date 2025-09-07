import XCTest
@testable import SmartCity

final class MapViewModelTests: XCTestCase {
    
    var sut: MapViewModel?
    var mockRepository: MockDownloadCitiesRepository?
    var useCase: DownloadCitiesUseCase?
    
    override func setUp() {
        super.setUp()
        mockRepository = MockDownloadCitiesRepository()
        useCase = DownloadCitiesUseCase(repository: mockRepository!)
        sut = MapViewModel(downloadCitiesUseCase: useCase!)
    }
    
    override func tearDown() {
        mockRepository?.reset()
        sut = nil
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testFetchDataIfNeededSuccess() async {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setSuccess()
        
        await sut.fetchDataIfNeeded()
        
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
    }
    
    func testFetchDataIfNeededError() async {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        enum TestError: Error { case networkError }
        mockRepository.setMockError(TestError.networkError)
        
        await sut.fetchDataIfNeeded()
        
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
        XCTAssertTrue(mockRepository.shouldThrowError)
    }
    
    func testFetchDataIfNeededWithDifferentErrors() async {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        enum CustomError: Error { case custom }
        mockRepository.setMockError(CustomError.custom)
        
        await sut.fetchDataIfNeeded()
        
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
        XCTAssertEqual(mockRepository.mockError as? CustomError, CustomError.custom)
    }
    
    func testMultipleFetchCalls() async {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setSuccess()
        
        await sut.fetchDataIfNeeded()
        await sut.fetchDataIfNeeded()
        await sut.fetchDataIfNeeded()
        
        XCTAssertEqual(mockRepository.fetchCallCount, 3)
    }
}