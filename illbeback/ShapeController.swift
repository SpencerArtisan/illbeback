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
    var corners: [ShapeCorner] = []
    var polyline: MKPolyline?
    var memories: MemoriesController!
    
    init(map: MKMapView, memories: MemoriesController) {
        self.map = map
        self.memories = memories
    }
    
    func move(corner: ShapeCorner) {
        drawShape()
        println(shapeContains(memories.here.coordinate))
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
        
        corners.removeAll(keepCapacity: true)
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
            var corner = corners[i]
            map!.addAnnotation(corner)
        }
    }

    func drawShape() {
        var points = shape()
        if (polyline != nil) {
            self.map.removeOverlay(polyline)
        }
        polyline = MKPolyline(coordinates: &points, count: points.count)
        self.map.addOverlay(polyline)
    }
    
    func pointAt(x: Double, y: Double) -> CLLocationCoordinate2D {
        return MKCoordinateForMapPoint(MKMapPointMake(x, y))
    }
    
    func shape() -> [CLLocationCoordinate2D] {
        var points = corners.map({(var corner) -> CLLocationCoordinate2D in corner.coordinate})
        points.append(points[0])
        return points
    }
    
    
    func shapeContains(test: CLLocationCoordinate2D) -> Bool {
        if corners.count <= 1 {
            return false //or if first point = test -> return true
        }

        var polygon = shape()
        
        
        var p = UIBezierPath()
        let firstPoint = toPoint(polygon[0]) as CGPoint
        
        p.moveToPoint(firstPoint)
        
        for index in 1...polygon.count-1 {
            p.addLineToPoint(toPoint(polygon[index]))
        }
        
        p.closePath()
        
        return p.containsPoint(toPoint(test))
    }
    
    func toPoint(coordinate: CLLocationCoordinate2D) -> CGPoint {
        return CGPointMake(CGFloat(coordinate.longitude), CGFloat(coordinate.latitude))
    }
}