//
//  Testing.swift
//  Sovran
//
//  Created by Brandon Sneed on 11/18/20.
//

import Foundation

/// Inquire as to whether we are within a Unit Testing environment.
#if DEBUG
extension Store {
    /// Resets the state system.  Useful for testing.
    internal func reset() {
        syncQueue.sync {
            subscribers.removeAll()
        }
        updateQueue.sync {
            states.removeAll()
        }
    }
}
#endif
