//
//  ShapeCorner.swift
//  illbeback
//
//  Created by Spencer Ward on 29/08/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class ShapeCorner : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coord: CLLocationCoordinate2D) {
        self.coordinate = coord
    }
}