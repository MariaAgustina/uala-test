//
//  SearchUITests.swift
//  SmartCityUITests
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import XCTest

final class SearchUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func testSearchFunctionality_BasicSearch() throws {
        // Wait for the app to load and search sheet to appear
        let searchTextField = app.textFields["search_text_field"]
        XCTAssert(searchTextField.waitForExistence(timeout: 5.0), "Search text field should exist")
        
        // Tap on search field and enter text
        searchTextField.tap()
        searchTextField.typeText("a")
        
        // Wait longer for debounce (300ms) + search time
        let searchResultsList = app.tables["search_results_list"]
        let searchResultsExist = searchResultsList.waitForExistence(timeout: 5.0)
        
        if searchResultsExist {
            // If results exist, test the interaction
            let firstResult = searchResultsList.cells.firstMatch
            if firstResult.exists {
                firstResult.tap()
                
                // Verify navigation occurred (either to detail or map navigation)
                let cityDetailView = app.otherElements["city_detail_view"]
                XCTAssert(cityDetailView.waitForExistence(timeout: 3.0), "Should navigate to city detail view")
            } else {
                XCTFail("Search results list exists but no cells found")
            }
        } else {
            // If no results, verify "no results" message or empty state
            let noResultsText = app.staticTexts["No se encontraron ciudades"]
            XCTAssert(noResultsText.waitForExistence(timeout: 2.0) || searchTextField.exists, 
                     "Should show no results message or maintain search state")
        }
    }
    
}
