//
//  ShapeController.swift
//  illbeback
//
//  Created by Spencer Ward on 29/08/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class ShapeController {
    var map: MKMapView!
    
    init(map: MKMapView) {
        self.map = map
    }
    
    func beginShape() {
        var mRect = self.map.visibleMapRect
        
        var maxX = MKMapRectGetMaxX(mRect)
        var minX = mRect.origin.x
        var maxY = MKMapRectGetMaxY(mRect)
        var minY = mRect.origin.y
        var width = maxX - minX
        var height = maxY - minY
        
        var p1 = pointAt(minX + width * 0.3, y: maxY - height / 5)
        var p2 = pointAt(minX + width * 0.7, y: maxY - height / 5)
        var p3 = pointAt(maxX - width * 0.1, y: maxY - height / 2)
        var p4 = pointAt(minX + width * 0.7, y: minY + height / 5)
        var p5 = pointAt(minX + width * 0.3, y: minY + height / 5)
        var p6 = pointAt(minX + width * 0.1, y: maxY - height / 2)
        
        var a = [p1, p2, p3, p4, p5, p6, p1]
        var polyline = MKPolyline(coordinates: &a, count: a.count)

        self.map.addOverlay(polyline)

        map!.addAnnotation(ShapeCorner(coord: p1))
        map!.addAnnotation(ShapeCorner(coord: p2))
        map!.addAnnotation(ShapeCorner(coord: p3))
        map!.addAnnotation(ShapeCorner(coord: p4))
        map!.addAnnotation(ShapeCorner(coord: p5))
        map!.addAnnotation(ShapeCorner(coord: p6))
    }
    
    func pointAt(x: Double, y: Double) -> CLLocationCoordinate2D {
        return MKCoordinateForMapPoint(MKMapPointMake(x, y))
    }
}