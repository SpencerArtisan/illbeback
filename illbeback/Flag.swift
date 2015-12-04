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
    private var _token: FlagToken
    
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
    }
    
    func invitees() -> [Invitee2] {
        return _token.invitees()
    }
    
    func state() -> FlagState {
        return _token.state()
    }
    
    func state(state: FlagState) {
        _token.state(state)
    }
    
    func description() -> String {
        return _token.descriptionUpdate() ?? _token.description()
    }
    
    func when() -> NSDate? {
        return _token.whenUpdate() ?? _token.when()
    }
    
    func location() -> CLLocationCoordinate2D {
        return _token.locationUpdate() ?? _token.location()
    }
    
    func type() -> String {
        return _token.type()
    }
    
    func originator() -> String {
        return _token.originator()
    }
    
    func share(friend: String) {
        let invitee = Invitee2(name: friend)
        _token.addInvitee(invitee)
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
        _token.offerUpdate(token)
    }
    
    func acceptUpdate() throws {
        guard state() == .UpdateOffered else {
            throw StateMachineError.InvalidTransition
        }
        _token.acceptUpdate()
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
        guard state() == .UpdateOffered else {
            throw StateMachineError.InvalidTransition
        }
        _token.declineUpdate()
        state(.DecliningUpdate)
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
    }
}