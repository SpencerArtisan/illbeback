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

public class Flag {
    private var _token: FlagToken
    private var dead = false
    
    static func create(id: String, type: String, description: String, location: CLLocationCoordinate2D, originator: String, orientation: UIDeviceOrientation?, when: NSDate?) -> Flag {
        let token = FlagToken(id: id, state: .Neutral, type: type, description: description, location: location, originator: originator, orientation: orientation, when: when)
        return Flag(token: token)
    }
    
    static func decode(encoded: String) -> Flag {
        return Flag(token: FlagToken(token: encoded))
    }
    
    private init(token: FlagToken) {
        _token = token
    }
    
    func encode() -> String {
        return _token.encode()
    }
    
    func isEvent() -> Bool {
        return _token.when() != nil
    }
    
    func isBlank() -> Bool {
        return _token.type() == "Blank"
    }
    
    func id() -> String {
        return _token.id()
    }
    
    func invitees() -> [Invitee2] {
        return _token.invitees()
    }
    
    func clearInvitees() {
        _token.clearInvitees()
        fireChangeEvent()
    }
    
    func findInvitee(name: String) -> Invitee2? {
        return _token.findInvitee(name)
    }
    
    func state() -> FlagState {
        return _token.state()
    }
    
    func description() -> String {
        return _token.descriptionUpdate() ?? _token.description()
    }
    
    func description(description: String) throws {
        guard canUpdate() else {
            throw StateMachineError.InvalidTransition
        }
        _token.description(description)
        fireChangeEvent()
    }
    
    func when() -> NSDate? {
        return _token.whenUpdate() ?? _token.when()
    }
    
    func when(when: NSDate?) throws{
        guard canUpdate() else {
            throw StateMachineError.InvalidTransition
        }
        _token.when(when)
        fireChangeEvent()
    }
    
    func daysToGo() -> Int {
        let fromNow = when()!.timeIntervalSinceDate(Utils.today())
        return Int(Int64(fromNow) / Int64(60*60*24))
    }
    
    func isPast() -> Bool {
        return when() != nil && when()!.timeIntervalSinceDate(Utils.today()) < 0
    }
    
    func whenFormatted() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        if formatter.stringFromDate(when()!) == "00:00" {
            formatter.dateFormat = "EEE dd MMMM"
        } else {
            formatter.dateFormat = "EEE d MMM HH:mm"
        }
        return formatter.stringFromDate(when()!)
    }
    
    func location() -> CLLocationCoordinate2D {
        return _token.locationUpdate() ?? _token.location()
    }
    
    func location(location: CLLocationCoordinate2D) {
        _token.location(location)
        fireChangeEvent()
    }
    
    func type() -> String {
        return _token.type()
    }
    
    func type(type: String) {
        _token.type(type)
        fireChangeEvent()
    }
    
    func originator() -> String {
        return _token.originator()
    }
    
    func summary() -> String {
        if description() == "" {
            return type()
        } else {
            let withoutReturns = description().stringByReplacingOccurrencesOfString("\r\n", withString: " ")
            return (withoutReturns as NSString).substringToIndex(min(withoutReturns.characters.count, 30))
        }
    }
    
    func invite(friend: String) {
        let invitee = Invitee2(name: friend)
        _token.addInvitee(invitee)
        fireChangeEvent()
    }
    
    func canUpdate() -> Bool {
        return state() == .Neutral || state() == .Accepting || (state() == .Declining && !dead)
    }
    
    func receivingNew(from: String) throws {
        _token.state(.ReceivingNew)
        _token.originator(from)
        fireChangeEvent()
    }
    
    func receivingUpdate(flag: Flag) {
        _token.pendingUpdate(flag._token)
        _token.state(.ReceivingUpdate)
        fireChangeEvent()
    }
    
    func receiveUpdateSuccess() throws {
        try state([.ReceivingUpdate], targetState: .ReceivedUpdate)
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
    
    func accepting() throws {
        let startState = state()
        try state([.ReceivedNew, .ReceivedUpdate], targetState: .Accepting)
        if startState == .ReceivedUpdate {
            _token.acceptUpdate()
            fireChangeEvent()
        }
    }
    
    func declining() throws {
        let startState = state()
        try state([.ReceivedNew, .ReceivedUpdate], targetState: .Declining)
        if startState == .ReceivedUpdate {
            _token.declineUpdate()
            fireChangeEvent()
        } else {
            dead = true
        }
    }
    
    func acceptSuccess() throws {
        try state([.Accepting], targetState: .Neutral)
    }
    
    func acceptFailure() throws {
        try state([.Accepting], targetState: .Accepting)
    }
    
    func declineSuccess() throws {
        if dead {
            try state([.Declining], targetState: .Dead)
        } else {
            try state([.Declining], targetState: .Neutral)
        }
    }
    
    func declineFailure() throws {
        try state([.Declining], targetState: .Declining)
    }
    
    func kill() {
        _token.state(.Dead)
        fireChangeEvent()
    }
    
    func reset(state: FlagState) {
        print("< ** RESET PROBLEM FLAG TO \(state): \(self) ** >")
        _token.declineUpdate()
        _token.state(.Neutral)
        fireChangeEvent()
    }

    private func state(acceptableStartStates: [FlagState], targetState: FlagState) throws {
        guard  acceptableStartStates.contains(state()) else {
            print("< ** INVALID FLAG State transition \(type()) from \(state()) to \(targetState) ** >")
            throw StateMachineError.InvalidTransition
        }
        _token.state(targetState)
        fireChangeEvent()
    }
    
    private func fireChangeEvent() {
        Utils.notifyObservers("FlagChanged", properties: ["flag": self])
    }
}

extension Flag: Equatable {}

public func ==(lhs: Flag, rhs: Flag) -> Bool {
    return lhs.id() == rhs.id()
}