//
//  SearchIntegrationTests.swift
//  SmartCityTests
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import XCTest
import CoreData
import Combine
@testable import SmartCity

final class SearchIntegrationTests: XCTestCase {

    var coreDataStack: CoreDataStack!
    var searchDataSource: SearchCityDataSource!
    var searchRepository: SearchCityRepository!
    var searchUseCase: SearchCityUseCase!
    var searchViewModel: SearchCityViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Setup in-memory Core Data stack for testing
        coreDataStack = CoreDataStack(modelName: "SmartCityData")
        coreDataStack.container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        
        // Wait for Core Data to load
        let expectation = expectation(description: "Core Data loaded")
        Task {
            try await coreDataStack.load()
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        
        // Setup search chain
        searchDataSource = SearchCityDataSource(coreDataStack: coreDataStack)
        searchRepository = SearchCityRepository(dataSource: searchDataSource)
        searchUseCase = SearchCityUseCase(repository: searchRepository)
        searchViewModel = SearchCityViewModel(searchCityUseCase: searchUseCase)
        
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        searchViewModel = nil
        searchUseCase = nil
        searchRepository = nil
        searchDataSource = nil
        coreDataStack = nil
        try super.tearDownWithError()
    }

    // MARK: - Data Setup Helpers
    
    private func insertTestCities() async throws {
        let testCities = [
            CityResponse(country: "Argentina", name: "Buenos Aires", id: 1, coord: Coordinate(lon: -58.3816, lat: -34.6037)),
            CityResponse(country: "Argentina", name: "Córdoba", id: 2, coord: Coordinate(lon: -64.1810, lat: -31.4201)),
            CityResponse(country: "Brazil", name: "São Paulo", id: 3, coord: Coordinate(lon: -46.6333, lat: -23.5505)),
            CityResponse(country: "Mexico", name: "México City", id: 4, coord: Coordinate(lon: -99.1332, lat: 19.4326)),
            CityResponse(country: "UK", name: "London", id: 5, coord: Coordinate(lon: -0.1276, lat: 51.5074)),
            CityResponse(country: "France", name: "Paris", id: 6, coord: Coordinate(lon: 2.3522, lat: 48.8566)),
            CityResponse(country: "Spain", name: "Madrid", id: 7, coord: Coordinate(lon: -3.7038, lat: 40.4168)),
            CityResponse(country: "US", name: "New York", id: 8, coord: Coordinate(lon: -74.0059, lat: 40.7128)),
            CityResponse(country: "US", name: "New York City", id: 9, coord: Coordinate(lon: -74.0059, lat: 40.7128)),
            CityResponse(country: "Germany", name: "Berlin", id: 10, coord: Coordinate(lon: 13.4050, lat: 52.5200))
        ]
        
        try await coreDataStack.saveCities(testCities)
    }

    // MARK: - Basic Search Tests
    
    func testBasicSearch_CityName() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "London")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "London")
        XCTAssertEqual(results.first?.country, "UK")
    }
    
    func testBasicSearch_CaseInsensitive() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "london")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "London")
    }
    
    func testBasicSearch_WithDiacritics() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "São Paulo")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "São Paulo")
        XCTAssertEqual(results.first?.country, "Brazil")
    }
    
    func testBasicSearch_DiacriticInsensitive() async throws {
        try await insertTestCities()
        
        // Search for "Sao Paulo" without diacritics should find "São Paulo"
        let results = try await searchUseCase.execute(query: "Sao Paulo")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "São Paulo")
    }

    // MARK: - Prefix Search Tests
    
    func testPrefixSearch_SingleResult() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "Lond")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "London")
    }
    
    func testPrefixSearch_MultipleResults() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "New")
        
        XCTAssertEqual(results.count, 2)
        let cityNames = results.map { $0.name }.sorted()
        XCTAssertEqual(cityNames, ["New York", "New York City"])
    }
    
    func testPrefixSearch_NoResults() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "Tokyo")
        
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - City + Country Search Tests
    
    func testCityCountrySearch_WithComma() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "Buenos Aires, Argentina")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Buenos Aires")
        XCTAssertEqual(results.first?.country, "Argentina")
    }
    
    func testCityCountrySearch_CountryCode() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "London, UK")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "London")
        XCTAssertEqual(results.first?.country, "UK")
    }
    
    func testCityCountrySearch_PartialCountry() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "New, US")
        
        XCTAssertEqual(results.count, 2)
        let cityNames = results.map { $0.name }.sorted()
        XCTAssertEqual(cityNames, ["New York", "New York City"])
        XCTAssertTrue(results.allSatisfy { $0.country == "US" })
    }
    
    func testCityCountrySearch_CityWithSpaces() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "New York City, US")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "New York City")
        XCTAssertEqual(results.first?.country, "US")
    }

    // MARK: - Sorting Tests
    
    func testSearchSorting_AlphabeticalByName() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "New")
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "New York")
        XCTAssertEqual(results[1].name, "New York City")
    }
    
    func testSearchSorting_SameCityDifferentCountries() async throws {
        // Add cities with same names in different countries
        let duplicateCities = [
            CityResponse(country: "Canada", name: "Paris", id: 11, coord: Coordinate(lon: -80.3832, lat: 43.2081)),
            CityResponse(country: "France", name: "Paris", id: 12, coord: Coordinate(lon: 2.3522, lat: 48.8566)),
            CityResponse(country: "US", name: "Paris", id: 13, coord: Coordinate(lon: -95.5555, lat: 33.6609))
        ]
        
        try await coreDataStack.saveCities(duplicateCities)
        
        let results = try await searchUseCase.execute(query: "Paris")
        
        XCTAssertEqual(results.count, 3)
        
        // Should be sorted by nameFolded first, then by country
        let expectedOrder = [
            ("Paris", "Canada"),
            ("Paris", "France"), 
            ("Paris", "US")
        ]
        
        for (index, expected) in expectedOrder.enumerated() {
            XCTAssertEqual(results[index].name, expected.0)
            XCTAssertEqual(results[index].country, expected.1)
        }
    }

    // MARK: - Limit Tests
    
    func testSearchLimit_Maximum20Results() async throws {
        // Insert 25 cities with same prefix
        var manyCities: [CityResponse] = []
        for i in 1...25 {
            manyCities.append(CityResponse(
                country: "Test Country \(i)",
                name: "Test City \(String(format: "%02d", i))",
                id: i,
                coord: Coordinate(lon: 0.0, lat: 0.0)
            ))
        }
        
        try await coreDataStack.saveCities(manyCities)
        
        let results = try await searchUseCase.execute(query: "Test")
        
        XCTAssertEqual(results.count, 20) // Should be limited to 20
    }

    // MARK: - Performance Tests
    
    func testSearchPerformance_LargeDataset() async throws {
        // Insert a larger dataset
        var largeCities: [CityResponse] = []
        for i in 1...1000 {
            largeCities.append(CityResponse(
                country: "Country \(i % 50)",
                name: "City \(String(format: "%04d", i))",
                id: i,
                coord: Coordinate(lon: Double(i) * 0.01, lat: Double(i) * 0.01)
            ))
        }
        
        try await coreDataStack.saveCities(largeCities)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let results = try await searchUseCase.execute(query: "City")
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertEqual(results.count, 20) // Limited to 20
        XCTAssertLessThan(timeElapsed, 0.1) // Should complete within 100ms
    }

    // MARK: - ViewModel Integration Tests
    
    func testViewModel_SearchResults() async throws {
        try await insertTestCities()
        
        let expectation = expectation(description: "Search completed")
        var receivedResults: [CityResponse] = []
        
        searchViewModel.$searchResults
            .dropFirst() // Skip initial empty state
            .sink { results in
                receivedResults = results
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        searchViewModel.searchQuery = "London"
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedResults.count, 1)
        XCTAssertEqual(receivedResults.first?.name, "London")
    }
    
    func testViewModel_EmptyQuery() async throws {
        try await insertTestCities()
        
        // Clear query
        searchViewModel.searchQuery = ""
        
        XCTAssertEqual(searchViewModel.searchResults.count, 0)
        XCTAssertFalse(searchViewModel.isSearching)
    }

    // MARK: - Error Handling Tests
    
    func testSearch_EmptyDatabase() async throws {
        // Don't insert any cities
        let results = try await searchUseCase.execute(query: "London")
        
        XCTAssertEqual(results.count, 0)
    }
    
    func testSearch_SpecialCharacters() async throws {
        try await insertTestCities()
        
        let results = try await searchUseCase.execute(query: "São")
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "São Paulo")
    }
    
    func testSearch_VeryLongQuery() async throws {
        try await insertTestCities()
        
        let longQuery = String(repeating: "a", count: 1000)
        let results = try await searchUseCase.execute(query: longQuery)
        
        XCTAssertEqual(results.count, 0) // No matches expected
    }
}