//
//  TextNormalizerTests.swift
//  SmartCityTests
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import XCTest
@testable import SmartCity

final class TextNormalizerTests: XCTestCase {

    // MARK: - fold() Tests
    
    func testFold_BasicLowercaseConversion() {
        let input = "Buenos Aires"
        let result = TextNormalizer.fold(input)
        
        XCTAssertEqual(result, "buenos aires")
    }
    
    func testFold_RemovesDiacritics() {
        let input = "São Paulo"
        let result = TextNormalizer.fold(input)
        
        XCTAssertEqual(result, "sao paulo")
    }
    
    func testFold_HandlesAccentedCharacters() {
        let testCases = [
            ("México", "mexico"),
            ("Bogotá", "bogota"),
            ("Córdoba", "cordoba"),
            ("José", "jose"),
            ("Zürich", "zurich"),
            ("Malmö", "malmo")
        ]
        
        for (input, expected) in testCases {
            let result = TextNormalizer.fold(input)
            XCTAssertEqual(result, expected, "Failed for input: \(input)")
        }
    }
    
    func testFold_EmptyString() {
        let input = ""
        let result = TextNormalizer.fold(input)
        
        XCTAssertEqual(result, "")
    }
    
    func testFold_AlreadyNormalizedString() {
        let input = "london"
        let result = TextNormalizer.fold(input)
        
        XCTAssertEqual(result, "london")
    }
    
    func testFold_MixedCaseWithDiacritics() {
        let input = "RÍO DE JANEIRO"
        let result = TextNormalizer.fold(input)
        
        XCTAssertEqual(result, "rio de janeiro")
    }
    
    func testFold_NumbersAndSpecialCharacters() {
        let input = "New York-123"
        let result = TextNormalizer.fold(input)
        
        XCTAssertEqual(result, "new york-123")
    }

    // MARK: - upperBoundForPrefix() Tests
    
    func testUpperBoundForPrefix_BasicIncrement() {
        let input = "london"
        let result = TextNormalizer.upperBoundForPrefix(input)
        
        // Last character 'n' should increment to 'o'
        XCTAssertEqual(result, "londoo")
    }
    
    func testUpperBoundForPrefix_SingleCharacter() {
        let input = "a"
        let result = TextNormalizer.upperBoundForPrefix(input)
        
        XCTAssertEqual(result, "b")
    }
    
    func testUpperBoundForPrefix_EmptyString() {
        let input = ""
        let result = TextNormalizer.upperBoundForPrefix(input)
        
        XCTAssertEqual(result, "")
    }
    
    func testUpperBoundForPrefix_EndsWithZ() {
        let input = "amazz"
        let result = TextNormalizer.upperBoundForPrefix(input)
        
        // Should increment 'z' to '{'
        XCTAssertEqual(result, "amaz{")
    }
    
    func testUpperBoundForPrefix_MultipleSameCharacters() {
        let input = "aaa"
        let result = TextNormalizer.upperBoundForPrefix(input)
        
        XCTAssertEqual(result, "aab")
    }

    // MARK: - Integration Tests (fold + upperBoundForPrefix)
    
    func testIntegration_FoldedStringWithUpperBound() {
        let cityName = "São Paulo"
        let folded = TextNormalizer.fold(cityName)
        let upperBound = TextNormalizer.upperBoundForPrefix(folded)
        
        XCTAssertEqual(folded, "sao paulo")
        XCTAssertEqual(upperBound, "sao paulp")
    }
    
    func testIntegration_SearchRangeBehavior() {
        let query = "Buenos"
        let foldedQuery = TextNormalizer.fold(query)
        let upperBound = TextNormalizer.upperBoundForPrefix(foldedQuery)
        
        // Test that cities starting with folded query would be in range
        let testCities = [
            "buenos aires",
            "buenos aires province", 
            "buenot", // This should NOT match
            "bueno" // This should NOT match
        ]
        
        for city in testCities {
            let shouldMatch = city >= foldedQuery && city < upperBound
            
            if city.hasPrefix(foldedQuery) {
                XCTAssertTrue(shouldMatch, "City '\(city)' should match range")
            } else {
                XCTAssertFalse(shouldMatch, "City '\(city)' should NOT match range")
            }
        }
    }

    // MARK: - Performance Tests
    
    func testPerformance_Fold() {
        let testString = "São Paulo, Buenos Aires, México City, Zürich"
        
        measure {
            for _ in 0..<1000 {
                _ = TextNormalizer.fold(testString)
            }
        }
    }
    
    func testPerformance_UpperBoundForPrefix() {
        let testString = "london"
        
        measure {
            for _ in 0..<1000 {
                _ = TextNormalizer.upperBoundForPrefix(testString)
            }
        }
    }
}
