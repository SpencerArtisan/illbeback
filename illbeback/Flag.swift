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
    
    func findInvitee(name: String) -> Invitee2? {
        return invitees().filter({$0.name() == name}).first
    }
    
    func state() -> FlagState {
        return _token.state()
    }
    
    func description() -> String {
        return _token.descriptionUpdate() ?? _token.description()
    }
    
    func description(description: String) {
        _token.description(description)
    }
    
    func when() -> NSDate? {
        return _token.whenUpdate() ?? _token.when()
    }
    
    func when(when: NSDate?) {
        _token.when(when)
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
    }
    
    func type() -> String {
        return _token.type()
    }
    
    func type(type: String) {
        _token.type(type)
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
    
    func receivingNew() throws {
        _token.state(.ReceivingNew)
    }
    
    func receivingUpdate(flag: Flag) {
        _token.pendingUpdate(flag._token)
        _token.state(.ReceivingUpdate)
    }
    
    func receiveUpdateSuccess() throws {
        try state(.ReceivingUpdate, targetState: .ReceivedUpdate)
    }
    
    func receiveNewSuccess() throws {
        try state(.ReceivingNew, targetState: .ReceivedNew)
    }
    
    func receiveUpdateFailure() throws {
        try state(.ReceivingUpdate, targetState: .ReceivingUpdate)
    }
    
    func receiveNewFailure() throws {
        try state(.ReceivingNew, targetState: .ReceivingNew)
    }
    
    func acceptUpdate() throws {
        try state(.ReceivedUpdate, targetState: .AcceptingUpdate)
        _token.acceptUpdate()
    }
    
    func acceptUpdateSuccess() throws {
        try state(.AcceptingUpdate, targetState: .Neutral)
    }
    
    func acceptUpdateFailure() throws {
        try state(.AcceptingUpdate, targetState: .AcceptingUpdate)
    }
    
    func declineUpdateSuccess() throws {
        try state(.DecliningUpdate, targetState: .Neutral)
    }
    
    func declineUpdateFailure() throws {
        try state(.DecliningUpdate, targetState: .DecliningUpdate)
    }
    
    func declineUpdate() throws {
        try state(.ReceivedUpdate, targetState: .DecliningUpdate)
        _token.declineUpdate()
    }

    func acceptNew() throws {
        try state(.ReceivedNew, targetState: .AcceptingNew)
    }
    
    func acceptNewSuccess() throws {
        try state(.AcceptingNew, targetState: .Neutral)
    }
    
    func acceptNewFailure() throws {
        try state(.AcceptingNew, targetState: .AcceptingNew)
    }
    
    func declineNewSuccess() throws {
        try state(.DecliningNew, targetState: .Dead)
    }
    
    func declineNewFailure() throws {
        try state(.DecliningNew, targetState: .DecliningNew)
    }
    
    func declineNew() throws {
        try state(.ReceivedNew, targetState: .DecliningNew)
    }

    private func state(acceptableStartState: FlagState, targetState: FlagState) throws {
        guard state() == acceptableStartState else {
            print("< ** INVALID FLAG State transition \(type()) from \(state()) to \(targetState) ** >")
            throw StateMachineError.InvalidTransition
        }
        _token.state(targetState)
    }

}

extension Flag: Equatable {}

public func ==(lhs: Flag, rhs: Flag) -> Bool {
    return lhs.id() == rhs.id()
}