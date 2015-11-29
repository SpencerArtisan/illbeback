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
    private var _token: FlagToken
    private var _updateOfferedToken: FlagToken?
    
    init() {
        _state = FlagState.Neutral
        _token = FlagToken(token: "")
    }
    
    func state() -> FlagState {
        return _state
    }
    
    func description() -> String? {
        return _updateOfferedToken != nil ? _updateOfferedToken?.description() : _token.description()
    }
    
    func update(description: String) throws {
        guard _state == .Neutral && _updateOfferedToken == nil else {
            throw StateMachineError.InvalidTransition
        }
        _token.description(description)
    }
    
    func externalUpdate(token: FlagToken) {
        _state = FlagState.UpdateOffered
        _updateOfferedToken = token
    }
    
    func acceptUpdate() throws {
        guard _state == .UpdateOffered && _updateOfferedToken != nil else {
            throw StateMachineError.InvalidTransition
        }
        _state = .AcceptingUpdate
        _token = _updateOfferedToken!
    }
    
    func acceptUpdateSuccess() {
        _state = .Neutral
    }
    
    func acceptUpdateFailure() {
        
    }
    
    func declineUpdate() throws {
        guard _state == .UpdateOffered && _updateOfferedToken != nil else {
            throw StateMachineError.InvalidTransition
        }
        _state = .DecliningUpdate
        _updateOfferedToken = nil
    }
}