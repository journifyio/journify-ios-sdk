//
//  State.swift
//  Journify
//
//

import Foundation
import Sovran

// MARK: - System (Overall)

struct System: State {
    let configuration: Configuration
    let running: Bool
    let enabled: Bool
        
    struct ToggleRunningAction: Action {
        let running: Bool
        
        func reduce(state: System) -> System {
            return System(configuration: state.configuration,
                          running: running,
                          enabled: state.enabled)
        }
    }
    
    struct ToggleEnabledAction: Action {
        let enabled: Bool
        
        func reduce(state: System) -> System {
            return System(configuration: state.configuration,
                          running: state.running,
                          enabled: enabled)
        }
    }
    
    struct UpdateConfigurationAction: Action {
        let configuration: Configuration
        
        func reduce(state: System) -> System {
            return System(configuration: configuration,
                          running: state.running,
                          enabled: state.enabled)
        }
    }
}


// MARK: - User information

struct UserInfo: Codable, State {
    let anonymousId: String
    let userId: String?
    let traits: JSON?
    let referrer: URL?
    
    struct ResetAction: Action {
        func reduce(state: UserInfo) -> UserInfo {
            return UserInfo(anonymousId: UUID().uuidString, userId: nil, traits: nil, referrer: nil)
        }
    }
    
    struct SetUserIdAction: Action {
        let userId: String
        
        func reduce(state: UserInfo) -> UserInfo {
            return UserInfo(anonymousId: state.anonymousId, userId: userId, traits: state.traits, referrer: state.referrer)
        }
    }
    
    struct SetTraitsAction: Action {
        let traits: JSON?
        
        func reduce(state: UserInfo) -> UserInfo {
            return UserInfo(anonymousId: state.anonymousId, userId: state.userId, traits: traits, referrer: state.referrer)
        }
    }
    
    struct SetUserIdAndTraitsAction: Action {
        let userId: String
        let traits: JSON?
        
        func reduce(state: UserInfo) -> UserInfo {
            return UserInfo(anonymousId: state.anonymousId, userId: userId, traits: traits, referrer: state.referrer)
        }
    }
    
    struct SetAnonymousIdAction: Action {
        let anonymousId: String
        
        func reduce(state: UserInfo) -> UserInfo {
            return UserInfo(anonymousId: anonymousId, userId: state.userId, traits: state.traits, referrer: state.referrer)
        }
    }
    
    struct SetReferrerAction: Action {
        let url: URL
        
        func reduce(state: UserInfo) -> UserInfo {
            return UserInfo(anonymousId: state.anonymousId, userId: state.userId, traits: state.traits, referrer: url)
        }
    }
}

// MARK: - Default State Setup

extension System {
    static func defaultState(configuration: Configuration, from storage: Storage) -> System {

        return System(configuration: configuration, running: false, enabled: true)
    }
}

extension UserInfo {
    static func defaultState(from storage: Storage) -> UserInfo {
        let userId: String? = storage.read(.userId)
        let traits: JSON? = storage.read(.traits)
        var anonymousId: String = UUID().uuidString.lowercased()
        if let existingId: String = storage.read(.anonymousId) {
            anonymousId = existingId
        }
        return UserInfo(anonymousId: anonymousId, userId: userId, traits: traits, referrer: nil)
    }
}
