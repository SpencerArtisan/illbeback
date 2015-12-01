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
    private var _location: CLLocationCoordinate2D
    private var _originator: String
    private var _state: FlagState
    private var _orientation: UIDeviceOrientation
    private var _when: NSDate?
    private var _invitees: [Invitee2]
    
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
        self._description = parts[1]
        let lat = parts[2]
        let long = parts[3]
        self._location = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (long as NSString).doubleValue)
        self._originator = parts[5]
        self._state = FlagState.fromCode(parts[6])
        self._orientation = parts.count > 7 ? (UIDeviceOrientation(rawValue: (parts[7] as NSString).integerValue))! : UIDeviceOrientation.Portrait
        self._invitees = parts.count > 9 && parts[9] != "" ? parts[9].componentsSeparatedByString(";").map{Invitee2(name: $0)} : []
        self._when = parts.count > 8 && parts[8] != "" ? formatter().dateFromString(parts[8]) : nil
    }
    
    func description() -> String {
        return _description
    }
    
    func description(description: String) {
        _description = description
    }
    
    func state() -> FlagState {
        return _state
    }
    
    func state(state: FlagState) {
        _state = state
    }
    
    private func decode(token: String) {
        
    }
    
    private func formatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }

    
    private func encode() {
        
    }
}