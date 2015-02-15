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
    var imagePath: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, imagePath: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.imagePath =  imagePath
    }
}