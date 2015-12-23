//
//  FlagAnnotation
//  illbeback
//
//  Created by Spencer Ward on 06/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//
import MapKit

class FlagAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var flag: Flag
    
    init(flag: Flag) {
        self.coordinate = flag.location()
        self.title = flag.type()
        self.subtitle = flag.description().isEmpty ? "No description provided" : flag.description()
        self.flag = flag
    }
    
    func setCoordinate2(newCoordinate: CLLocationCoordinate2D) {
        coordinate = newCoordinate
        flag.location(newCoordinate)
    }
}