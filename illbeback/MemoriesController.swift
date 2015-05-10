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
    
    var addMemory: AddMemoryController!
    var rephotoController: RephotoController!
    var rememberController: RememberController!
    var shareModal: Modal?
    var pinToShare: MapPinView?
    let user = User()
    var messageModals: [Modal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        initMap()
        initMemories()
        self.shareModal = Modal(viewName: "ShareView", owner: self)
        self.addMemory = AddMemoryController(album: photoAlbum)
        self.rephotoController = RephotoController(album: photoAlbum)
        self.rememberController = RememberController(album: photoAlbum)
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.pushViewController(rememberController, animated: true)
    }
    
    // Callback for button on the callout
    func rephotoMemory(pin: MapPinView) {
        if (self.navigationController?.topViewController != rephotoController) {
            rephotoController.pinToRephoto = pin
            self.navigationController?.navigationBarHidden = false
            self.navigationController?.pushViewController(rephotoController!, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        memoryAlbum.downloadNewShares(user, callback: {memory in
            var messageModal = Modal(viewName: "MessageView", owner: self)
            var message = messageModal.findElementByTag(1) as! UIButton
            message.backgroundColor = CategoryController.getColorForCategory(memory.type)
            var title = "New " + memory.type + " from " + memory.originator
            message.setTitle(title, forState: UIControlState.Normal)
            messageModal.slideDownFromTop(self.view)
            self.messageModals.append(messageModal)
            message.addTarget(self, action: "dismissMessage:", forControlEvents: .TouchUpInside)
        })
    }

    func dismissMessage(sender: AnyObject?) {
        var messageModal = messageModals.removeLast()
        messageModal.slideUpFromTop(self.view)
        ((sender) as! UIButton).removeTarget(self, action: "dismissMessage:", forControlEvents: .TouchUpInside)
    }

    func initMemories() {
        memoryAlbum = MemoryAlbum(map: map)
        memoryAlbum.addToMap()
    }
    
    func initLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    func initMap() {
        map.delegate = self
        var tapRecognizer = UILongPressGestureRecognizer(target: self, action: "foundTap:")
        map.addGestureRecognizer(tapRecognizer)
        map.showsPointsOfInterest = false
        map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
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
        here = locations[0] as! CLLocation
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
        var cancelButton = shareModal?.findElementByTag(2) as! UIButton
        var shareButton = shareModal?.findElementByTag(1) as! UIButton
        shareButton.setTitle(" " + user.getFriend(), forState: UIControlState.Normal)
        pinToShare = pin
        shareButton.addTarget(self, action: "shareMemoryConfirmed:", forControlEvents: .TouchUpInside)
        delay(1) { cancelButton.addTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside) }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func shareMemoryConfirmed(sender: AnyObject?) {
        memoryAlbum.share(pinToShare!, from: user.getName(), to: user.getFriend())
        pinToShare = nil
        shareModal?.slideInFromLeft(self.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareMemoryConfirmed:", forControlEvents: .TouchUpInside)
    }
    
    func shareMemoryCancelled(sender: AnyObject?) {
        pinToShare = nil
        shareModal?.slideInFromLeft(self.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
    }
    
    // Callback for button on the callout
    func rewordMemory(pin: MapPinView) {
        map.deselectAnnotation(pin.annotation, animated: false)
        pin.refresh()
        addMemory.reword(self, memory: pin.memory!)
    }

    // Callback for display pins on map
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MapPin) {
            let pinData = annotation as! MapPin
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as! MapPinView!
        
            if (pinView == nil) {
                var imageUrl = photoAlbum.getImagePath(pinData.memory.id)
                pinView = MapPinView(memoriesController: self, memory: pinData.memory, imageUrl: imageUrl)
            }
        
            return pinView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Starting
        {
            view.dragState = MKAnnotationViewDragState.Dragging
        }
        else if newState == MKAnnotationViewDragState.Ending || newState == MKAnnotationViewDragState.Canceling
        {
            view.dragState = MKAnnotationViewDragState.None;
            if (view.annotation is MapPin) {
                let pinData = view.annotation as! MapPin
                pinData.setCoordinate2(pinData.coordinate)
                self.memoryAlbum.save()
            }
        }
    }
}

