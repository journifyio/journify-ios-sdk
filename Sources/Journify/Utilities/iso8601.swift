//
//  iso8601.swift
//  Journify
//
//

import Foundation

enum JournifyISO8601DateFormatter {
    
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.update(with: .withFractionalSeconds)
        return formatter
    }()
}

internal extension Date {
    // TODO: support nanoseconds
    func iso8601() -> String {
        return JournifyISO8601DateFormatter.shared.string(from: self)
    }
}

internal extension String {
    func iso8601() -> Date? {
        return JournifyISO8601DateFormatter.shared.date(from: self)
    }
}
