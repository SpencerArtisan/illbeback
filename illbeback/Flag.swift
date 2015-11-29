//
//  Flag.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Flag {
    private var _state: FlagState
    private var _description: String?
    
    init() {
        _state = FlagState.Neutral
    }
    
    func state() -> FlagState {
        return _state
    }
    
    func description() -> String? {
        return _description
    }
    
    func update(description: String) throws {
        guard _state == .Neutral else {
            throw StateMachineError.InvalidTransition
        }
        _description = description
    }
    
    func externalUpdate(token: FlagToken) {
        _state = FlagState.UpdateOffered
        _description = token.description()
    }
}