//
//  Flag.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Flag {
    private var _invitees: [Invitee2]
    private var _token: FlagToken
    private var _updateOfferedToken: FlagToken?
    
    
    static func create(id: String, type: String, description: String, location: CLLocationCoordinate2D, originator: String, orientation: UIDeviceOrientation?, when: NSDate?) -> Flag {
        let token = FlagToken(id: id, state: .Neutral, type: type, description: description, location: location, originator: originator, orientation: orientation, when: when)
        return Flag(token: token)
    }
    
    static func offered(token: FlagToken) -> Flag {
        token.state(.NewOffered)
        return Flag(token: token)
    }
    
    private init(token: FlagToken) {
        _token = token
        _invitees = []
    }
    
    func invitees() -> [Invitee2] {
        return _invitees
    }
    
    func state() -> FlagState {
        return _token.state()
    }
    
    
    func state(state: FlagState) {
        _token.state(state)
    }
    
    func description() -> String? {
        return _updateOfferedToken != nil ? _updateOfferedToken?.description() : _token.description()
    }
    
    func share(friend: String) {
        let invitee = Invitee2(name: friend)
        _invitees.append(invitee)
    }
    
    func update(description: String) throws {
        guard canUpdate() else {
            throw StateMachineError.InvalidTransition
        }
        _token.description(description)
    }
    
    func canUpdate() -> Bool {
        return state() == .Neutral || state() == .AcceptingUpdate || state() == .DecliningUpdate ||
               state() == .AcceptingNew
    }
    
    func externalUpdate(token: FlagToken) {
        _token.state(.UpdateOffered)
        _updateOfferedToken = token
    }
    
    func acceptUpdate() throws {
        guard state() == .UpdateOffered && _updateOfferedToken != nil else {
            throw StateMachineError.InvalidTransition
        }
        _token = _updateOfferedToken!
        state(.AcceptingUpdate)
    }
    
    func acceptUpdateSuccess() {
        state(.Neutral)
    }
    
    func acceptUpdateFailure() {
    }
    
    func declineUpdateSuccess() {
        state(.Neutral)
    }
    
    func declineUpdateFailure() {
    }
    
    func declineUpdate() throws {
        guard state() == .UpdateOffered && _updateOfferedToken != nil else {
            throw StateMachineError.InvalidTransition
        }
        state(.DecliningUpdate)
        _updateOfferedToken = nil
    }

    func acceptNew() throws {
        guard state() == .NewOffered else {
            throw StateMachineError.InvalidTransition
        }
        state(.AcceptingNew)
    }
    
    func acceptNewSuccess() {
        state(.Neutral)
    }
    
    func acceptNewFailure() {
    }
    
    func declineNewSuccess() {
        state(.Dead)
    }
    
    func declineNewFailure() {
    }
    
    func declineNew() throws {
        guard state() == .NewOffered else {
            throw StateMachineError.InvalidTransition
        }
        state(.DecliningNew)
        _updateOfferedToken = nil
    }
}