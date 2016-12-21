//
//  Invitee.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

open class Invitee {
    fileprivate var _name: String
    fileprivate var _state: InviteeState
    
    init(name: String) {
        _name = name
        _state = .Inviting
    }
    
    init(code: String) {
        let parts = code.components(separatedBy: ",")
        _name = parts[0]
        _state = InviteeState.fromCode(parts[1])
    }
    
    func name() -> String {
        return _name
    }
    
    func state() -> InviteeState {
        return _state
    }
    
    func inviteSuccess() {
        state(.Invited)
    }
    
    func inviteFailure() {
    }
    
    func accepting() {
        state(.Accepting)
    }
    
    func declining() {
        state(.Declining)
    }
    
    func acceptSuccess() {
        state(.Accepted)
    }
    
    func acceptFailure() {
    }
    
    func declineSuccess() {
        state(.Declined)
    }
    
    func declineFailure() {
    }
    
    func encode() -> String {
        return "\(_name),\(_state.rawValue)"
    }
    
    fileprivate func state(_ state: InviteeState) {
        print("< INVITEE State transition \(_name) from \(_state) to \(state) >")
        _state = state
        Utils.notifyObservers("InviteeChanged", properties: [:])
    }
}


extension Invitee: Equatable {}

public func ==(lhs: Invitee, rhs: Invitee) -> Bool {
    return lhs.name() == rhs.name()
}
