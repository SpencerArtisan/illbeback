//
//  FlagToken.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class FlagToken {
    fileprivate var _type: String
    fileprivate var _id: String
    fileprivate var _description: String
    fileprivate var _descriptionUpdate: String?
    fileprivate var _location: CLLocationCoordinate2D
    fileprivate var _locationUpdate: CLLocationCoordinate2D?
    fileprivate var _originator: String
    fileprivate var _sender: String?
    fileprivate var _state: FlagState
    fileprivate var _when: Date?
    fileprivate var _whenUpdate: Date?
    fileprivate var _invitees: [Invitee]
    
    init(id: String, state: FlagState, type: String, description: String, location: CLLocationCoordinate2D, originator: String, orientation: UIDeviceOrientation?, when: Date?) {
        self._id = id
        self._type = type
        self._description = description
        self._location = location
        self._originator = originator
        self._state = state
        self._when = when
        self._invitees = []
    }
    
    init(token: String) {
        let parts = token.components(separatedBy: ":")
        self._id = parts[4]
        
        self._type = parts[0]
        let descriptionParts = parts[1].components(separatedBy: "|")
        self._description = descriptionParts[0]
        if descriptionParts.count == 2 {
            self._descriptionUpdate = descriptionParts[1]
        }
        
        let latParts = parts[2].components(separatedBy: ",")
        let longParts = parts[3].components(separatedBy: ",")
        self._location = CLLocationCoordinate2D(latitude: (latParts[0] as NSString).doubleValue, longitude: (longParts[0] as NSString).doubleValue)
        if latParts.count == 2 && latParts[1] != "" && longParts.count == 2 && longParts[1] != "" {
            self._locationUpdate = CLLocationCoordinate2D(latitude: (latParts[1] as NSString).doubleValue, longitude: (longParts[1] as NSString).doubleValue)
        }
        
        let originatorAndSender = parts[5].components(separatedBy: "|")
        self._originator = originatorAndSender[0]
        if originatorAndSender.count == 2 {
            self._sender = originatorAndSender[1]
        }
        
        self._state = FlagState.fromCode(parts[6])

        if parts.count > 9 {
            self._invitees = parts[9] != "" ? parts[9].components(separatedBy: ";").map { Invitee(code: $0) } : []
        } else {
            self._invitees = []
        }
        
        if parts.count > 8 {
            let whenParts = parts[8].components(separatedBy: ",")
            self._when = dateFromString(whenParts[0])
            if whenParts.count == 2 {
                self._whenUpdate = dateFromString(whenParts[1])
            }
        }
    }

    
    func pendingUpdate(_ token: FlagToken) {
        _descriptionUpdate = token.description()
        _locationUpdate = token.location()
        _whenUpdate = token.when()
    }
    
    func hasPendingUpdate() -> Bool {
        return _locationUpdate != nil
    }
    
    func acceptUpdate() {
        _description = _descriptionUpdate!
        _location = _locationUpdate!
        _when = _whenUpdate
        _descriptionUpdate = nil
        _locationUpdate = nil
        _whenUpdate = nil
    }
    
    func declineUpdate() {
        _descriptionUpdate = nil
        _locationUpdate = nil
        _whenUpdate = nil
    }
    
    func id() -> String {
        return _id
    }
    
    func type() -> String {
        return _type
    }

    func type(_ type: String) {
        _type = type
    }
    
    func originator() -> String {
        return _originator
    }
    
    func originator(_ originator: String) {
        _originator = originator
    }
    
    func sender() -> String? {
        return _sender
    }
    
    func sender(_ sender: String) {
        _sender = sender
    }
    
    func invitees() -> [Invitee] {
        return _invitees
    }
    
    func invitees(_ invitees: [Invitee]) {
        _invitees = invitees
    }
    
    func clearInvitees() {
        _invitees = []
    }
    
    func findInvitee(_ name: String) -> Invitee? {
        return invitees().filter({$0.name() == name}).first
    }
    
    func addInvitee(_ invitee: Invitee) {
        let oldInvitee = findInvitee(invitee.name())
        if oldInvitee != nil {
            _invitees.removeObject(oldInvitee!)
        }
        
        _invitees.append(invitee)
    }
    
    func description() -> String {
        return _description
    }
    
    func description(_ description: String) {
        _description = description
    }
    
    func location() -> CLLocationCoordinate2D {
        return _location
    }
    
    func location(_ location: CLLocationCoordinate2D) {
        _location = location
    }
    
    func when() -> Date? {
        return _when
    }
    
    func when(_ when: Date?) {
        _when = when
    }
    
    func descriptionUpdate() -> String? {
        return _descriptionUpdate
    }
    
    func locationUpdate() -> CLLocationCoordinate2D? {
        return _locationUpdate
    }

    func whenUpdate() -> Date? {
        return _whenUpdate
    }

    func state() -> FlagState {
        return _state
    }
    
    func state(_ state: FlagState) {
        print("< FLAG State transition \(self._type) from \(self._state) to \(state) >")
        self._state = state
    }
    
    func encode() -> String {
        let whenString = _when != nil ? formatter().string(from: _when!) : ""
        let whenUpdateString = _whenUpdate != nil ? formatter().string(from: _whenUpdate!) : ""
        let inviteesString = _invitees.map{$0.encode()}.joined(separator: ";")
        let latitudeUpdateString = _locationUpdate == nil ? "" : "\(_locationUpdate!.latitude)"
        let longitudeUpdateString = _locationUpdate == nil ? "" : "\(_locationUpdate!.longitude)"
        let descriptionUpdateString = _descriptionUpdate == nil ? "" : "|\(_descriptionUpdate!)"
        let senderString = _sender == nil ? "" : "|\(_sender!)"
        return "\(_type):\(_description)\(descriptionUpdateString):\(_location.latitude),\(latitudeUpdateString):\(_location.longitude),\(longitudeUpdateString):\(_id):\(_originator)\(senderString):\(_state.code()):UNUSED:\(whenString),\(whenUpdateString):\(inviteesString)"
    }
    
    func whenFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if formatter.string(from: _when!) == "00:00" {
            formatter.dateFormat = "EEE dd MMMM"
        } else {
            formatter.dateFormat = "EEE d MMM HH:mm"
        }
        return formatter.string(from: _when!)
    }

    private func dateFromString(_ value: String) -> Date? {
        var value = value
        if value != "" && !value.contains("-") {
            value += " 00-00-00-000"
        }
        return value != "" ? formatter().date(from: value) : nil
    }
    
    fileprivate func formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy HH-mm-ss-SSS"
        return formatter
    }

}
