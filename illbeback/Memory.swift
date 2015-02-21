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
    private var type: String
    private var id: String
    private var description: String
    private var location: CLLocationCoordinate2D
    
    init(id: String, type: String, description: String, location: CLLocationCoordinate2D) {
        self.id = id
        self.type = type
        self.description = description
        self.location = location
    }
    
    init(memoryString: String) {
        var parts = memoryString.componentsSeparatedByString(":")
        self.id = parts[4]
        self.type = parts[0]
        self.description = parts[1]
        let lat = parts[2]
        let long = parts[3]
        self.location = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (long as NSString).doubleValue)
    }
    
    func asString() -> String {
        return "\(type):\(description):\(location.latitude):\(location.longitude):\(id)"
    }
    
    func asMapPin() -> MapPin {
        return MapPin(coordinate: location, title: type, subtitle: description, id: id)
    }
}