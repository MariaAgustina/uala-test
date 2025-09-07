import Foundation
@testable import SmartCity

final class MockSearchCityRepository: SearchCityRepositoryProtocol {
    
    var mockResults: [CityResponse] = []
    var mockError: Error?
    var searchCallCount = 0
    var lastQuery: String?
    
    func searchCities(query: String) async throws -> [CityResponse] {
        searchCallCount += 1
        lastQuery = query
        
        if let mockError = mockError {
            throw mockError
        }
        
        return mockResults
    }
    
    func reset() {
        mockResults = []
        mockError = nil
        searchCallCount = 0
        lastQuery = nil
    }
    
    func setMockResults(_ cities: [CityResponse]) {
        mockResults = cities
        mockError = nil
    }
    
    func setMockError(_ error: Error) {
        mockError = error
        mockResults = []
    }
}