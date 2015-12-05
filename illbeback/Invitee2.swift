//
//  Invitee2.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Invitee2 {
    private var _name: String
    private var _state: InviteeState
    
    init(name: String) {
        _name = name
        _state = .Inviting
    }
    
    init(code: String) {
        let parts = code.componentsSeparatedByString(",")
        _name = parts[0]
        _state = InviteeState.fromCode(parts[1])
    }
    
    func name() -> String {
        return _name
    }
    
    func state() -> InviteeState {
        return _state
    }
    
    func invitingSuccess() {
        _state = .Invited
    }
    
    func invitingFailure() {
        
    }
    
    func accepted() {
        _state = .Accepted
    }
    
    func declined() {
        _state = .Declined
    }
    
    func encode() -> String {
        return "\(_name),\(_state.rawValue)"
    }
}