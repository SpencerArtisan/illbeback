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


class MemoriesController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    var here: CLLocation!
    var memoryAlbum: MemoryAlbum!
    let photoAlbum = PhotoAlbum()
    
    var addMemory: AddMemoryController!
    var rephotoController: RephotoController!
    var rememberController: RememberController!
    var zoomController: ZoomController!
    var shareModal: Modal?
    var newUserModal: Modal?
    var searchModal: Modal?
    var pinToShare: MapPinView?
    let user = User()
    var messageModals: [Modal] = []
    var newUserLabel: UILabel!
    var newUserText: UITextView!
    
    @IBOutlet weak var sharingName: UITextView!
    
    @IBOutlet weak var searchText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        initMap()
        initMemories()
        self.shareModal = Modal(viewName: "ShareView", owner: self)
        self.newUserModal = Modal(viewName: "NewUser", owner: self)
        self.searchModal = Modal(viewName: "SearchView", owner: self)
        self.addMemory = AddMemoryController(album: photoAlbum)
        self.rephotoController = RephotoController(album: photoAlbum, memoryAlbum: memoryAlbum)
        self.rememberController = RememberController(album: photoAlbum)
        self.zoomController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ZoomController") as! ZoomController

        self.newUserLabel = newUserModal!.findElementByTag(1) as! UILabel!
        self.newUserText = newUserModal!.findElementByTag(2) as! UITextView!
        self.newUserText.delegate = self
        self.searchText.delegate = self
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.pushViewController(rememberController, animated: true)
    }
    
    
    @IBAction func currentLocation(sender: AnyObject) {
        self.map.setCenterCoordinate(here.coordinate, animated: true)
    }
    
    @IBAction func search(sender: AnyObject) {
        searchText.becomeFirstResponder()
        searchText.text = ""
        searchModal?.slideOutFromLeft(self.view)
    }
    
    // Callback for button on the callout
    func rephotoMemory(pin: MapPinView) {
        if (self.navigationController?.topViewController != rephotoController) {
            rephotoController.pinToRephoto = pin
            self.navigationController?.navigationBarHidden = false
            self.navigationController?.pushViewController(rephotoController!, animated: true)
        }
    }
    
    // Callback for button on the callout
    func zoomPicture(pin: MapPinView) {
        if (self.navigationController?.topViewController != zoomController) {
            self.navigationController?.navigationBarHidden = false
            let photoView: UIImageView = zoomController.view.subviews[0] as! UIImageView
            photoView.image = pin.photoView?.image
            self.navigationController?.pushViewController(zoomController, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        var delaySeconds = 0.0
        
        ensureUserKnown()
        
        memoryAlbum.downloadNewShares(user, callback: {memory in
            var color = CategoryController.getColorForCategory(memory.type)
            var title = "New " + memory.type + " from " + memory.originator
            self.delay(delaySeconds) {
                self.showMessage(title, color: color, time: 3)
            }
            
            delaySeconds += 4
        })
    }
    
    private func ensureUserKnown() {
        if (!user.hasName()) {
            newUserLabel.text = "Your sharing name"
            newUserText.becomeFirstResponder()
            newUserText.text = ""
            newUserModal?.slideOutFromRight(self.view)
        }
    }
    
    private func showMessage(text: String, color: UIColor, time: Double) {
        var messageModal = Modal(viewName: "MessageView", owner: self)
        var message = messageModal.findElementByTag(1) as! UIButton
        message.backgroundColor = color
        message.setTitle(text, forState: UIControlState.Normal)
        messageModal.slideDownFromTop(self.view)
        
        delay(time) {
            messageModal.slideUpFromTop(self.view)
        }
    }

    func dismissMessage(sender: AnyObject?) {
        var messageModal = messageModals.removeLast()
        messageModal.slideUpFromTop(self.view)
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
    func addMemoryHere(type: String, id: String, description: String, location: CLLocationCoordinate2D?, orientation: UIDeviceOrientation) {
        var actualLocation = location == nil ? here.coordinate : location!
        var memory = Memory(id: id, type: type, description: description, location: actualLocation, user: user, orientation: orientation)
        memoryAlbum.add(memory)
    }
    
    // Callback for button on the callout
    func deleteMemory(pin: MapPinView) {
        memoryAlbum.delete(pin)
    }

    // Callback for button on the callout
    func updateMemory(pin: MapPinView) {
        map!.removeAnnotation(pin.annotation)
        map!.addAnnotation(pin.memory?.asMapPin())
        memoryAlbum.save()
    }
    
    // Callback for button on the callout
    func shareMemory(pin: MapPinView) {
        shareModal?.slideOutFromLeft(self.view)
        pinToShare = pin

        var tag = 3
        let friends: [String] = user.getFriends()
        for friend in friends {
            var shareButton = shareModal?.findElementByTag(tag++) as! UIButton
            shareButton.setTitle(" " + friend, forState: UIControlState.Normal)
            shareButton.hidden = false
            shareButton.addTarget(self, action: "shareMemoryConfirmed:", forControlEvents: .TouchUpInside)
            shareButton.enabled = false
            delay(0.5) { shareButton.enabled = true }
        }
        
        var newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        if (friends.count > 7) {
            newFriendButton.hidden = true
        } else {
            newFriendButton.addTarget(self, action: "shareWithNewFriend:", forControlEvents: .TouchUpInside)
            newFriendButton.enabled = false
            delay(0.5) { newFriendButton.enabled = true }
        }
        var cancelButton = shareModal?.findElementByTag(1) as! UIButton
        cancelButton.addTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
        cancelButton.enabled = false
        delay(0.5) { cancelButton.enabled = true }
    }

    func shareMemoryConfirmed(sender: AnyObject?) {
        var friend = (sender as! UIButton).titleLabel?.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        shareWith(friend!)
        hideShareModal(sender)
    }
    
    func shareWith(friend: String) {
        var memory = pinToShare?.memory
        var color = CategoryController.getColorForCategory(memory!.type)
        var title = "Shared " + memory!.type + " with " + friend
        self.showMessage(title, color: color, time: 1.6)

        memoryAlbum.share(pinToShare!, from: user.getName(), to: friend)
        pinToShare = nil
    }

    func hideShareModal(sender: AnyObject?) {
        shareModal?.slideInFromLeft(self.view)
    }
    
    func shareWithNewFriend(sender: AnyObject?) {
        hideShareModal(sender)
        newUserLabel.text = "Your friend's name"
        newUserText.becomeFirstResponder()
        newUserText.text = ""
        newUserModal?.slideOutFromRight(self.view)
        var cancelButton2 = newUserModal?.findElementByTag(4) as! UIButton
        cancelButton2.addTarget(self, action: "shareNewFriendCancelled:", forControlEvents: .TouchUpInside)
        cancelButton2.enabled = false
        delay(0.5) { cancelButton2.enabled = true }
    }

    // Callback for new friend dialogs
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        textView.text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        if (text == "\n" && !textView.text.isEmpty) {
            if (textView == self.searchText) {
                println("SEARCH TEXT \(textView.text)")
                searchModal?.slideInFromLeft(self.view)
                searchText.resignFirstResponder()
                
                var geocoder = CLGeocoder()
                geocoder.geocodeAddressString(textView.text, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                    if let placemark = placemarks?[0] as? CLPlacemark {
                        self.map.setCenterCoordinate(placemark.location.coordinate, animated: true)
                    }
                })
            } else {
                println("NEW USER TEXT \(textView.text)")
        
                newUserModal?.slideInFromRight(self.view)

                if (!user.hasName()) {
                    user.setName(textView.text)
                    newUserText.resignFirstResponder()
                } else {
                    user.addFriend(textView.text)
                    newUserText.resignFirstResponder()
                    shareWith(textView.text)
                }
            }
            
            return false
        }
        return true
        
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func shareMemoryCancelled(sender: AnyObject?) {
        pinToShare = nil
        shareModal?.slideInFromLeft(self.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
    }
    
    func shareNewFriendCancelled(sender: AnyObject?) {
        newUserText.resignFirstResponder()
        pinToShare = nil
        newUserModal?.slideInFromRight(self.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareNewFriendCancelled:", forControlEvents: .TouchUpInside)
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

