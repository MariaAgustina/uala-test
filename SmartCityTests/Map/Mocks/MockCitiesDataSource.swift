import Foundation
@testable import SmartCity

final class MockCitiesDataSource: CitiesDataSourceProtocol {
    
    var mockResult: CitiesResponse = []
    var mockError: Error?
    var fetchCallCount = 0
    var shouldThrowError = false
    
    func fetchCities() async throws -> CitiesResponse {
        fetchCallCount += 1
        
        if shouldThrowError, let mockError = mockError {
            throw mockError
        }
        
        return mockResult
    }
    
    func reset() {
        mockResult = []
        mockError = nil
        fetchCallCount = 0
        shouldThrowError = false
    }
    
    func setMockResult(_ cities: CitiesResponse) {
        mockResult = cities
        mockError = nil
        shouldThrowError = false
    }
    
    func setMockError(_ error: Error) {
        mockError = error
        shouldThrowError = true
        mockResult = []
    }
    
    func setSuccess() {
        mockError = nil
        shouldThrowError = false
    }
}