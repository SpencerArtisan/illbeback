//
//  MapPin.swift
//  illbeback
//
//  Created by Spencer Ward on 06/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//
import MapKit

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    var memory: Memory
    
    init(memory: Memory) {
        self.coordinate = memory.location
        self.title = memory.type
        self.subtitle = memory.description.isEmpty ? "No description provided" : memory.description
        self.memory = memory
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        coordinate = newCoordinate
        memory.location = newCoordinate
    }
}