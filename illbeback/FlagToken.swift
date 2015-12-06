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
    private var _type: String
    private var _id: String
    private var _description: String
    private var _descriptionUpdate: String?
    private var _location: CLLocationCoordinate2D
    private var _locationUpdate: CLLocationCoordinate2D?
    private var _originator: String
    private var _state: FlagState
    private var _orientation: UIDeviceOrientation
    private var _when: NSDate?
    private var _whenUpdate: NSDate?
    private var _invitees: [Invitee2]
    private var _inviteesUpdate: [Invitee2]?
    
    init(id: String, state: FlagState, type: String, description: String, location: CLLocationCoordinate2D, originator: String, orientation: UIDeviceOrientation?, when: NSDate?) {
        self._id = id
        self._type = type
        self._description = description
        self._location = location
        self._originator = originator
        self._state = state
        self._orientation = orientation ?? UIDeviceOrientation.FaceUp
        self._when = when
        self._invitees = []
    }
    
    init(token: String) {
        var parts = token.componentsSeparatedByString(":")
        self._id = parts[4]
        self._type = parts[0]
        let descriptionParts = parts[1].componentsSeparatedByString(",")
        self._description = descriptionParts[0]
        if descriptionParts.count == 2 {
            self._descriptionUpdate = descriptionParts[1]
        }
        let latParts = parts[2].componentsSeparatedByString(",")
        let longParts = parts[3].componentsSeparatedByString(",")
        self._location = CLLocationCoordinate2D(latitude: (latParts[0] as NSString).doubleValue, longitude: (longParts[0] as NSString).doubleValue)
        if latParts.count == 2 && latParts[1] != "" && longParts.count == 2 && longParts[1] != "" {
            self._locationUpdate = CLLocationCoordinate2D(latitude: (latParts[1] as NSString).doubleValue, longitude: (longParts[1] as NSString).doubleValue)
        }
        self._originator = parts[5]
        self._state = FlagState.fromCode(parts[6])
        self._orientation = parts.count > 7 ? (UIDeviceOrientation(rawValue: (parts[7] as NSString).integerValue))! : UIDeviceOrientation.Portrait

        if parts.count > 9 {
            let inviteeParts = parts[9].componentsSeparatedByString("|")
            self._invitees = inviteeParts[0] != "" ? inviteeParts[0].componentsSeparatedByString(";").map{Invitee2(code: $0)} : []
            if inviteeParts.count == 2 {
                self._inviteesUpdate = inviteeParts[1] != "" ? inviteeParts[1].componentsSeparatedByString(";").map{Invitee2(code: $0)} : []
            }
        } else {
            self._invitees = []
        }
        
        if parts.count > 8 {
            let whenParts = parts[8].componentsSeparatedByString(",")
            self._when = whenParts[0] != "" ? formatter().dateFromString(whenParts[0]) : nil
            if whenParts.count == 2 {
                self._whenUpdate = whenParts[1] != "" ? formatter().dateFromString(whenParts[1]) : nil
            }
        }
    }
    
    func offerUpdate(token: FlagToken) {
        _descriptionUpdate = token.description()
        _locationUpdate = token.location()
        _whenUpdate = token.when()
        _inviteesUpdate = token.invitees()
    }
    
    func acceptUpdate() {
        _description = _descriptionUpdate!
        _location = _locationUpdate!
        _when = _whenUpdate
        _invitees = _inviteesUpdate!
        _descriptionUpdate = nil
        _locationUpdate = nil
        _whenUpdate = nil
        _inviteesUpdate = nil
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

    func type(type: String) {
        _type = type
    }
    
    func originator() -> String {
        return _originator
    }
    
    func invitees() -> [Invitee2] {
        return _invitees
    }
    
    func inviteesUpdate() -> [Invitee2]? {
        return _inviteesUpdate
    }
    
    func addInvitee(invitee: Invitee2) {
        _invitees.append(invitee)
    }
    
    func description() -> String {
        return _description
    }
    
    func description(description: String) {
        _description = description
    }
    
    func location() -> CLLocationCoordinate2D {
        return _location
    }
    
    func location(location: CLLocationCoordinate2D) {
        _location = location
    }
    
    func when() -> NSDate? {
        return _when
    }
    
    func when(when: NSDate?) {
        _when = when
    }
    
    func descriptionUpdate() -> String? {
        return _descriptionUpdate
    }
    
    func locationUpdate() -> CLLocationCoordinate2D? {
        return _locationUpdate
    }

    func whenUpdate() -> NSDate? {
        return _whenUpdate
    }

    func state() -> FlagState {
        return _state
    }
    
    func state(state: FlagState) {
        print("< FLAG State transition \(_type) from \(_state) to \(state) >")
        _state = state
    }
    
    func encode() -> String {
        let whenString = _when != nil ? formatter().stringFromDate(_when!) : ""
        let whenUpdateString = _whenUpdate != nil ? formatter().stringFromDate(_whenUpdate!) : ""
        let inviteesString = _invitees.map{$0.encode()}.joinWithSeparator(";")
        let inviteesUpdateString = _inviteesUpdate == nil ? "" : ("|" + _inviteesUpdate!.map{$0.encode()}.joinWithSeparator(";"))
        let latitudeUpdateString = _locationUpdate == nil ? "" : "\(_locationUpdate!.latitude)"
        let longitudeUpdateString = _locationUpdate == nil ? "" : "\(_locationUpdate!.longitude)"
        let descriptionUpdateString = _descriptionUpdate == nil ? "" : ",\(_descriptionUpdate!)"
        return "\(_type):\(_description)\(descriptionUpdateString):\(_location.latitude),\(latitudeUpdateString):\(_location.longitude),\(longitudeUpdateString):\(_id):\(_originator):\(_state.code()):\(_orientation.rawValue):\(whenString),\(whenUpdateString):\(inviteesString)\(inviteesUpdateString)"
    }
    
    func whenFormatted() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        if formatter.stringFromDate(_when!) == "00:00" {
            formatter.dateFormat = "EEE dd MMMM"
        } else {
            formatter.dateFormat = "EEE d MMM HH:mm"
        }
        return formatter.stringFromDate(_when!)
    }

    private func formatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMMM yyyy HH-mm-ss-SSS"
        return formatter
    }

}