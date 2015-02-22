//
//  Memory.swift
//  illbeback
//
//  Created by Spencer Ward on 21/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import CoreLocation

public class Memory {
    private let DEFAULT_ORIGINATOR = "Spencer"
    var type: String
    var id: String
    var description: String
    var location: CLLocationCoordinate2D
    var originator: String
    var recentShare = false
    
    init(id: String, type: String, description: String, location: CLLocationCoordinate2D, user: User) {
        self.id = id
        self.type = type
        self.description = description
        self.location = location
        self.originator = user.getName()
    }
    
    init(memoryString: String) {
        var parts = memoryString.componentsSeparatedByString(":")
        self.id = parts[4]
        self.type = parts[0]
        self.description = parts[1]
        let lat = parts[2]
        let long = parts[3]
        self.location = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (long as NSString).doubleValue)
        self.originator = parts.count > 5 ? parts[5] : DEFAULT_ORIGINATOR
    }
    
    func asString() -> String {
        return "\(type):\(description):\(location.latitude):\(location.longitude):\(id):\(originator)"
    }
    
    func asMapPin() -> MapPin {
        return MapPin(memory: self)
    }
}