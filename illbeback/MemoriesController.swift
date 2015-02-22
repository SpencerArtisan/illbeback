//
//  SecondViewController.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MemoriesController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    var here: CLLocation!
    var memoryAlbum: MemoryAlbum!
    let photoAlbum = PhotoAlbum()
    let addMemory = AddMemoryController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        initMap()
        initMemories()
    }
    
    func initMemories() {
        memoryAlbum = MemoryAlbum(map: map)
        memoryAlbum.downloadNewShares()
        memoryAlbum.addToMap(map)
    }
    
    func initLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    func initMap() {
        map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        map.delegate = self
        var tapRecognizer = UILongPressGestureRecognizer(target: self, action: "foundTap:")
        self.map.addGestureRecognizer(tapRecognizer)
    }
    
    // User clicked on map - Add a memory there
    func foundTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Began) {
            var point = recognizer.locationInView(self.map)
            var tapPoint = self.map.convertPoint(point, toCoordinateFromView: self.view)
            self.addMemory.add(self, location: tapPoint)
        }
    }

    // Callback for location updates
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        here = locations[0] as CLLocation
    }

    // Callback for button on the UI
    func addMemoryHere(type: String, id: String, description: String, location: CLLocationCoordinate2D?) {
        var actualLocation = location == nil ? here.coordinate : location!
        var memory = Memory(id: id, type: type, description: description, location: actualLocation)
        memoryAlbum.add(memory)
    }
    
    // Callback for button on the UI
    func deleteMemory(pin: MapPinView) {
        memoryAlbum.delete(pin)
    }

    // Callback for display pins on map
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MapPin) {
            let pinData = annotation as MapPin
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MapPinView!
        
            if (pinView == nil) {
                var imageUrl = photoAlbum.getImagePath(pinData.id)
                pinView = MapPinView(memoriesController: self, memoryId: pinData.id, imageUrl: imageUrl, title: pinData.title, subtitle: pinData.subtitle)
                pinView.annotation = annotation
                pinView.enabled = true
                
            
                let pinImage : UIImage = UIImage(named: pinData.title)!
                pinView.image = pinImage
            }
        
            return pinView
        }
        return nil
    }
}

