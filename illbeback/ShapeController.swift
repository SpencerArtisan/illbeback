//
//  ShapeController.swift
//  illbeback
//
//  Created by Spencer Ward on 29/08/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class ShapeController : UIViewController {
    var map: MKMapView!
    var corners: [ShapeCorner] = []
    var polyline: MKPolyline?
    var mapController: MapController!
    
    init(map: MKMapView, mapController: MapController) {
        super.init(nibName: nil, bundle: nil)
        self.map = map
        self.mapController = mapController
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clear() {
        if polyline != nil {
            self.map.removeOverlay(polyline!)
        }
        for corner in corners {
            map!.removeAnnotation(corner)
        }
        corners.removeAll(keepingCapacity: true)
    }
    
    func move(_ corner: ShapeCorner) {
        drawShape()
    }
    
    func beginShape() {
        clear()
        
        let mRect = self.map.visibleMapRect
        
        let maxX = mRect.maxX
        let minX = mRect.origin.x
        let maxY = mRect.maxY
        let minY = mRect.origin.y
        let width = maxX - minX
        let height = maxY - minY
        
        let p1 = pointAt(minX + width * 0.3, y: maxY - height / 5)
        let p2 = pointAt(minX + width * 0.7, y: maxY - height / 5)
        let p3 = pointAt(maxX - width * 0.1, y: maxY - height / 2)
        let p4 = pointAt(minX + width * 0.7, y: minY + height / 5)
        let p5 = pointAt(minX + width * 0.3, y: minY + height / 5)
        let p6 = pointAt(minX + width * 0.1, y: maxY - height / 2)
        
        corners.append(ShapeCorner(coord: p1))
        corners.append(ShapeCorner(coord: p2))
        corners.append(ShapeCorner(coord: p3))
        corners.append(ShapeCorner(coord: p4))
        corners.append(ShapeCorner(coord: p5))
        corners.append(ShapeCorner(coord: p6))

        drawCorners()
        drawShape()
    }
    
    func drawCorners() {
        for i in 0...corners.count - 1 {
            let corner = corners[i]
            map!.addAnnotation(corner)
        }
    }

    func drawShape() {
        var points = shape()
        if (polyline != nil) {
            self.map.removeOverlay(polyline!)
        }
        polyline = MKPolyline(coordinates: &points, count: points.count)
        self.map.addOverlay(polyline!)
    }
    
    func pointAt(_ x: Double, y: Double) -> CLLocationCoordinate2D {
        return MKMapPoint(x: x, y: y).coordinate
    }
    
    func shape() -> [CLLocationCoordinate2D] {
        var points = corners.map({(corner) -> CLLocationCoordinate2D in corner.coordinate})
        points.append(points[0])
        return points
    }
    
    
    func shapeContains(_ test: CLLocationCoordinate2D) -> Bool {
        if corners.count <= 1 {
            return false //or if first point = test -> return true
        }

        let polygon = shape()
        
        let p = UIBezierPath()
        let firstPoint = toPoint(polygon[0]) as CGPoint
        
        p.move(to: firstPoint)
        
        for index in 1...polygon.count-1 {
            p.addLine(to: toPoint(polygon[index]))
        }
        
        p.close()
        
        return p.contains(toPoint(test))
    }
    
    func toPoint(_ coordinate: CLLocationCoordinate2D) -> CGPoint {
        return CGPoint(x: CGFloat(coordinate.longitude), y: CGFloat(coordinate.latitude))
    }
}
