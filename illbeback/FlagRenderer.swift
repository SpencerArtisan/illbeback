//
//  FlagRenderer.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class FlagRenderer {
    private var map: MKMapView
    
    init(map: MKMapView) {
        self.map = map
    }

    func add(flag: Flag) {
        Utils.runOnUiThread() {
            let pin = self.asMapPin(flag)
            print("Adding pin for \(flag.encode())")
            self.map.addAnnotation(pin)
        }
    }
    
    func asMapPin(flag: Flag) -> MapPin {
        return MapPin(flag: flag)
    }
}