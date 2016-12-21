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

open class Flag {
    fileprivate var _token: FlagToken
    fileprivate var dead = false
    
    static func create(_ id: String, type: String, description: String, location: CLLocationCoordinate2D, originator: String, orientation: UIDeviceOrientation?, when: Date?) -> Flag {
        let token = FlagToken(id: id, state: .Neutral, type: type, description: description, location: location, originator: originator, orientation: orientation, when: when)
        return Flag(token: token)
    }
    
    static func decode(_ encoded: String) -> Flag {
        return Flag(token: FlagToken(token: encoded))
    }
    
    init(token: FlagToken) {
        _token = token
    }
    
    func isPendingAccept() -> Bool {
        return state() == .ReceivedUpdate || state() == .ReceivedNew ||  state() == .ReceivingUpdate || state() == .ReceivingNew
    }
    
    func encode() -> String {
        return _token.encode()
    }
    
    func isEvent() -> Bool {
        return _token.type() == "Event"
    }
    
    func isBlank() -> Bool {
        return _token.type() == "Blank"
    }
    
    func id() -> String {
        return _token.id()
    }
    
    func invitees() -> [Invitee] {
        return _token.invitees()
    }
    
    func clearInvitees() {
        _token.clearInvitees()
        fireChangeEvent()
    }
    
    func findInvitee(_ name: String) -> Invitee? {
        return _token.findInvitee(name)
    }
    
    func state() -> FlagState {
        return _token.state()
    }
    
    func description() -> String {
        return _token.descriptionUpdate() ?? _token.description()
    }
    
    func description(_ description: String) throws {
        guard canUpdate() else {
            throw StateMachineError.invalidTransition
        }
        _token.description(description)
        fireChangeEvent()
    }
    
    func when() -> Date? {
        return _token.whenUpdate() as Date?? ?? _token.when() as Date?
    }
    
    func when(_ when: Date?) throws{
        guard canUpdate() else {
            throw StateMachineError.invalidTransition
        }
        _token.when(when)
        fireChangeEvent()
    }
    
    func daysToGo() -> Int {
        let fromNow = when()!.timeIntervalSince(Utils.today() as Date)
        return Int(Int64(fromNow) / Int64(60*60*24))
    }
    
    func isPast() -> Bool {
        return when() != nil && when()!.timeIntervalSince(Utils.today() as Date) < 0
    }
    
    func whenFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if formatter.string(from: when()!) == "00:00" {
            formatter.dateFormat = "EEE dd MMMM"
        } else {
            formatter.dateFormat = "EEE d MMM HH:mm"
        }
        return formatter.string(from: when()!)
    }
    
    func location() -> CLLocationCoordinate2D {
        return _token.locationUpdate() ?? _token.location()
    }
    
    func location(_ location: CLLocationCoordinate2D) {
        _token.location(location)
        fireChangeEvent()
    }
    
    func type() -> String {
        return _token.type()
    }
    
    func type(_ type: String) {
        _token.type(type)
        fireChangeEvent()
    }
    
    func originator() -> String {
        return _token.originator()
    }
    
    func sender() -> String? {
        return _token.sender()
    }
    
    func summary() -> String {
        if description() == "" {
            return type()
        } else {
            let withoutReturns = description().replacingOccurrences(of: "\r\n", with: " ")
            return (withoutReturns as NSString).substring(to: min(withoutReturns.characters.count, 30))
        }
    }
    
    func invite(_ friend: String) -> Invitee {
        let invitee = Invitee(name: friend)
        _token.addInvitee(invitee)
        print("Added invitee.  Invitees now \(_token.invitees())")
        fireChangeEvent()
        return invitee
    }
    
    func accepting(_ friend: String) -> Invitee {
        var invitee = _token.findInvitee(friend)
        if _token.hasPendingUpdate() {
            _token.acceptUpdate()
        }
        if invitee != nil {
            invitee!.accepting()
        } else {
            print("Warning.  Accepting invitee can't find themselves in the invitee list")
            invitee = invite(friend)
            invitee!.accepting()
        }
        fireChangeEvent()
        return invitee!
    }
    
    func acceptSuccess(_ invitee: Invitee) {
        invitee.acceptSuccess()
        _token.state(.Neutral)
        fireChangeEvent()
    }
    
    func acceptFailure(_ invitee: Invitee) {
        invitee.acceptFailure()
    }
    
    func declineSuccess(_ invitee: Invitee) {
        invitee.declineSuccess()
        if dead {
            kill()
        } else {
            _token.state(.Neutral)
            fireChangeEvent()
        }
    }
    
    func declineFailure(_ invitee: Invitee) {
        invitee.declineFailure()
    }
    
    func declining(_ friend: String) -> Invitee {
        var invitee = _token.findInvitee(friend)
        if !_token.hasPendingUpdate() || state() == .ReceivedNew {
            print("No pending updates or received new, so putting flag on death row")
            dead = true
        }
        if _token.hasPendingUpdate() {
            _token.declineUpdate()
        }
        if invitee != nil {
            invitee!.declining()
        } else {
            print("Warning.  Declining invitee can't find themselves in the invitee list")
            invitee = invite(friend)
            invitee!.declining()
        }
        fireChangeEvent()
        return invitee!
    }
    
    func canUpdate() -> Bool {
        return state() == .Neutral && !dead
    }
    
    func receivingNew(_ from: String) throws {
        _token.state(.ReceivingNew)
        _token.sender(from)
        fireChangeEvent()
    }
    
    func receivingUpdate(_ from: String, flag: Flag) {
        _token.pendingUpdate(flag._token)
        _token.sender(from)
        if state() == .ReceivedNew {
            _token.state(.ReceivingNew)
        } else {
            _token.state(.ReceivingUpdate)
        }
        
        flag.invitees().forEach {invitee in
                let existingInvitee = self._token.findInvitee(invitee.name())
                if existingInvitee == nil {
                    self._token.addInvitee(invitee)
                }
        }
        
        fireChangeEvent()
    }
    
    func receiveUpdateSuccess() throws {
        if state() == .ReceivingNew {
            _token.state(.ReceivedNew)
        } else {
            _token.state(.ReceivedUpdate)
        }
    }
    
    func receiveNewSuccess() throws {
        try state([.ReceivingNew], targetState: .ReceivedNew)
    }
    
    func receiveUpdateFailure() throws {
        try state([.ReceivingUpdate], targetState: .ReceivingUpdate)
    }
    
    func receiveNewFailure() throws {
        try state([.ReceivingNew], targetState: .ReceivingNew)
    }
    
    func kill() {
        _token.state(.Dead)
        fireChangeEvent()
    }
    
    func reset(_ state: FlagState) {
        print("< ** RESET PROBLEM FLAG TO \(state): \(self) ** >")
        _token.declineUpdate()
        _token.state(.Neutral)
        fireChangeEvent()
    }

    fileprivate func state(_ acceptableStartStates: [FlagState], targetState: FlagState) throws {
        if !acceptableStartStates.contains(state()) {
            print("< ** INVALID FLAG State transition \(type()) from \(state()) to \(targetState) ** >")            
        }
//        guard  acceptableStartStates.contains(state()) else {
//            print("< ** INVALID FLAG State transition \(type()) from \(state()) to \(targetState) ** >")
////            throw StateMachineError.InvalidTransition
//        }
            self._token.state(targetState)
            self.fireChangeEvent()
    }
    
    fileprivate func fireChangeEvent() {
        Utils.notifyObservers("FlagChanged", properties: ["flag": self])
    }
}

extension Flag: Equatable {}

public func ==(lhs: Flag, rhs: Flag) -> Bool {
    return lhs.id() == rhs.id()
}
