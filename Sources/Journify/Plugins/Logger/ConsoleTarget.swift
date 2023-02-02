//
//  ConsoleTarget.swift
//  ConsoleTarget
//
//

import Foundation

class ConsoleTarget: LogTarget {
    func parseLog(_ log: LogMessage) {
        var metadata = ""
        if let function = log.function, let line = log.line {
            metadata = " - \(function):\(line)"
        }
        print("[Journify \(log.kind.toString())\(metadata)]\n\(log.message)\n")
    }
}
