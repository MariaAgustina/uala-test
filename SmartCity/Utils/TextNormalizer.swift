//
//  TextUtils.swift
//  SmartCity
//
//  Created by Maria Agustina Markosich on 05/09/2025.
//

import Foundation

struct TextNormalizer {
    static func fold(_ text: String) -> String {
        return text.folded
    }
    
    static func upperBoundForPrefix(_ prefix: String) -> String {
        guard let last = prefix.unicodeScalars.last else {
            return prefix
        }
        if let incremented = UnicodeScalar(last.value + 1) {
            let newPrefix = prefix.dropLast() + String(incremented)
            return String(newPrefix)
        } else {
            return prefix + "\u{0001}"
        }
    }
}

extension String {
    var folded: String {
        return self.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
