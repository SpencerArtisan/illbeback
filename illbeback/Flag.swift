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
    
    static func create() -> Flag {
        return Flag(state: .Neutral, token: FlagToken(token: ""))
    }
    
    static func offered(token: FlagToken) -> Flag {
        return Flag(state: .NewOffered, token: token)
    }
    
    private init(state: FlagState, token: FlagToken) {
        _state = state
        _token = token
    }
    
    func state() -> FlagState {
        return _state
    }
    
    func description() -> String? {
        return _updateOfferedToken != nil ? _updateOfferedToken?.description() : _token.description()
    }
    
    func update(description: String) throws {
        guard canUpdate() else {
            throw StateMachineError.InvalidTransition
        }
        _token.description(description)
    }
    
    func canUpdate() -> Bool {
        return _state == .Neutral || _state == .AcceptingUpdate || _state == .DecliningUpdate ||
               _state == .AcceptingNew 
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
    
    func declineUpdateSuccess() {
        _state = .Neutral
    }
    
    func declineUpdateFailure() {
        
    }
    
    func declineUpdate() throws {
        guard _state == .UpdateOffered && _updateOfferedToken != nil else {
            throw StateMachineError.InvalidTransition
        }
        _state = .DecliningUpdate
        _updateOfferedToken = nil
    }

    func acceptNew() throws {
        guard _state == .NewOffered else {
            throw StateMachineError.InvalidTransition
        }
        _state = .AcceptingNew
    }
    
    func acceptNewSuccess() {
        _state = .Neutral
    }
    
    func acceptNewFailure() {
        
    }
    
    func declineNewSuccess() {
        _state = .Dead
    }
    
    func declineNewFailure() {
        
    }
    
    func declineNew() throws {
        guard _state == .NewOffered else {
            throw StateMachineError.InvalidTransition
        }
        _state = .DecliningNew
        _updateOfferedToken = nil
    }
}