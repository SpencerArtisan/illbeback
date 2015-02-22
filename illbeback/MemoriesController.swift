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
    var shareModal: Modal?
    var pinToShare: MapPinView?
    let user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        initMap()
        initMemories()
        self.shareModal = Modal(viewName: "ShareView", owner: self)
    }
    
    func initMemories() {
        memoryAlbum = MemoryAlbum(map: map)
        memoryAlbum.downloadNewShares(user)
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
        var memory = Memory(id: id, type: type, description: description, location: actualLocation, user: user)
        memoryAlbum.add(memory)
    }
    
    // Callback for button on the callout
    func deleteMemory(pin: MapPinView) {
        memoryAlbum.delete(pin)
    }
    
    // Callback for button on the callout
    func shareMemory(pin: MapPinView) {
        shareModal?.slideOutFromLeft(self.view)
        var shareButton = shareModal?.findElementByTag(1) as UIButton
        shareButton.setTitle(" " + user.getFriend(), forState: UIControlState.Normal)
        pinToShare = pin
        shareButton.addTarget(self, action: "shareMemoryConfirmed:", forControlEvents: .TouchUpInside)
    }
    
    func shareMemoryConfirmed(sender: AnyObject?) {
        memoryAlbum.share(pinToShare!, from: user.getName(), to: user.getFriend())
        pinToShare = nil
        shareModal?.slideInFromLeft(self.view)
        ((sender) as UIButton).removeTarget(self, action: "shareMemoryConfirmed:", forControlEvents: .TouchUpInside)
    }
    
    // Callback for display pins on map
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MapPin) {
            let pinData = annotation as MapPin
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MapPinView!
        
            if (pinView == nil) {
                var imageUrl = photoAlbum.getImagePath(pinData.memory.id)
                pinView = MapPinView(memoriesController: self, memory: pinData.memory, imageUrl: imageUrl, title: pinData.title, subtitle: pinData.subtitle)
            }
        
            return pinView
        }
        return nil
    }
}

