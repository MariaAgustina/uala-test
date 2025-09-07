import XCTest
import Combine
@testable import SmartCity

final class SearchCityViewModelTests: XCTestCase {
    
    var sut: SearchCityViewModel?
    var mockRepository: MockSearchCityRepository?
    var useCase: SearchCityUseCase?
    var cancellables: Set<AnyCancellable>?
    
    override func setUp() {
        super.setUp()
        mockRepository = MockSearchCityRepository()
        useCase = SearchCityUseCase(repository: mockRepository!)
        sut = SearchCityViewModel(searchCityUseCase: useCase!)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables?.forEach { $0.cancel() }
        cancellables = nil
        sut = nil
        useCase = nil
        mockRepository?.reset()
        mockRepository = nil
        super.tearDown()
    }
    
    func testInitialState() {
        guard let sut = sut else {
            XCTFail("SUT not initialized")
            return
        }
        
        XCTAssertEqual(sut.searchResults, [])
        XCTAssertFalse(sut.isSearching)
        XCTAssertEqual(sut.searchQuery, "")
    }
    
    func testSearchWithValidQuery() {
        guard let sut = sut,
              let mockRepository = mockRepository,
              var cancellables = cancellables else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        let expectedCities = [
            CityResponse(country: "AR", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037))
        ]
        mockRepository.setMockResults(expectedCities)
        
        let expectation = expectation(description: "Search completed")
        
        sut.$searchResults
            .dropFirst()
            .sink { results in
                XCTAssertEqual(results.count, 1)
                XCTAssertEqual(results.first?.name, "Buenos Aires")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchQuery = "Buenos"
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testSearchWithEmptyQuery() {
        guard let sut = sut,
              let mockRepository = mockRepository else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setMockResults([CityResponse(country: "AR", name: "Test", id: 1, coord: Coordinate(lon: 0, lat: 0))])
        
        sut.searchQuery = ""
        
        XCTAssertEqual(sut.searchResults, [])
        XCTAssertFalse(sut.isSearching)
        XCTAssertEqual(mockRepository.searchCallCount, 0)
    }
    
    func testSearchError() {
        guard let sut = sut,
              let mockRepository = mockRepository,
              var cancellables = cancellables else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        enum TestError: Error { case networkError }
        mockRepository.setMockError(TestError.networkError)
        
        let expectation = expectation(description: "Search error handled")
        
        sut.$searchResults
            .dropFirst()
            .sink { results in
                XCTAssertEqual(results, [])
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchQuery = "Error"
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testIsSearchingState() {
        guard let sut = sut,
              let mockRepository = mockRepository,
              var cancellables = cancellables else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setMockResults([])
        
        let expectation = expectation(description: "Search completed")
        var searchingStates: [Bool] = []
        
        sut.$isSearching
            .sink { isSearching in
                searchingStates.append(isSearching)
                if !isSearching && searchingStates.count >= 2 {
                    XCTAssertTrue(searchingStates.contains(true))
                    if let lastState = searchingStates.last {
                        XCTAssertFalse(lastState)
                    }
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.searchQuery = "Test"
        
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockRepository.searchCallCount, 1)
    }
    
    func testDebounceMultipleQueries() {
        guard let sut = sut,
              let mockRepository = mockRepository,
              var cancellables = cancellables else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setMockResults([])
        
        let expectation = expectation(description: "Only last query executed")
        
        sut.$searchResults
            .dropFirst()
            .sink { _ in
                XCTAssertEqual(mockRepository.searchCallCount, 1)
                XCTAssertEqual(mockRepository.lastQuery, "ABCD")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchQuery = "A"
        sut.searchQuery = "AB"
        sut.searchQuery = "ABC"
        sut.searchQuery = "ABCD"
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testRemoveDuplicateQueries() {
        guard let sut = sut,
              let mockRepository = mockRepository,
              var cancellables = cancellables else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockRepository.setMockResults([])
        
        let expectation = expectation(description: "Duplicate query ignored")
        
        sut.$searchResults
            .dropFirst()
            .sink { _ in
                XCTAssertEqual(mockRepository.searchCallCount, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchQuery = "Test"
        sut.searchQuery = "Test"
        sut.searchQuery = "Test"
        
        waitForExpectations(timeout: 1.0)
    }
}
