//
//  String+Extension.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 17/09/26.
//

import Foundation

nonisolated extension String {

    /// Trims leading/trailing whitespace and newlines.
    /// Use this everywhere user input is captured before storing/comparing it.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Trimmed + true if nothing meaningful is left.
    var isBlank: Bool {
        trimmed.isEmpty
    }

    /// Case-insensitive equality, ignoring leading/trailing whitespace on both sides.
    /// Replaces the repeated `.trimmingCharacters(...).caseInsensitiveCompare(...) == .orderedSame` pattern.
    func equalsIgnoringCaseAndWhitespace(_ other: String) -> Bool {
        trimmed.caseInsensitiveCompare(other.trimmed) == .orderedSame
    }

    /// Locale-aware "contains", ignoring case and diacritics — the standard choice
    /// for search/filter UI (matches what `.searchable` users expect).
    func containsIgnoringCase(_ other: String) -> Bool {
        guard !other.isBlank else { return false }
        return localizedCaseInsensitiveContains(other.trimmed)
    }
}
