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
    
    var shapeController: ShapeController!
    var addMemory: AddMemoryController!
    var rephotoController: RephotoController!
    var rememberController: RememberController!
    var zoomController: ZoomSwipeController!
    var shareController: ShareController!

    var newUserModal: Modal?
    var searchModal: Modal?
    var shapeModal: Modal?

    let user = User()
    var messageModals: [Modal] = []
    var newUserLabel: UILabel!
    var newUserText: UITextView!
    
    @IBOutlet weak var sharingName: UITextView!
    
    @IBOutlet weak var searchText: UITextView!
    
    func getView() -> UIView {
        return self.view
    }
    
    @IBAction func cancel(sender: AnyObject) {
        shapeController.clear()
        showPinsInShape()
        shapeModal?.slideUpFromTop(view)
    }
    
    @IBAction func share(sender: AnyObject) {
        var sharing:[MapPinView] = []
        
        let allPins = map.annotations
        for pin in allPins {
            if (pin is MapPin) {
                let mapPin = pin as! MapPin
                if shapeController.shapeContains(mapPin.memory.location) {
                    let pinView = map.viewForAnnotation(mapPin) as! MapPinView
                    sharing.append(pinView)
                }
            }
        }

        shareController.shareMemory(sharing)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        initMap()
        initMemories()
        self.newUserModal = Modal(viewName: "NewUser", owner: self)
        self.searchModal = Modal(viewName: "SearchView", owner: self)
        self.shapeModal = Modal(viewName: "ShapeOptions", owner: self)
        self.addMemory = AddMemoryController(album: photoAlbum, memoriesViewController: self)
        self.rephotoController = RephotoController(photoAlbum: photoAlbum, memoryAlbum: memoryAlbum)
        self.rememberController = RememberController(album: photoAlbum, memoriesController: self)
        self.zoomController = ZoomSwipeController()
        self.shapeController = ShapeController(map: map, memories: self)
        self.shareController = ShareController(user: user, memories: self)

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
        let span = MKCoordinateSpan(latitudeDelta: 0.016, longitudeDelta: 0.016)
        let region = MKCoordinateRegion(center: here.coordinate, span: span)
        self.map.setRegion(region, animated: true)
        
    }
    
    @IBAction func search(sender: AnyObject) {
        searchText.becomeFirstResponder()
        searchText.text = ""
        searchModal?.slideOutFromLeft(self.view)
    }
    
    @IBAction func cancelSearch(sender: AnyObject) {
        searchModal?.slideInFromLeft(self.view)
        searchText.resignFirstResponder()
    }
    
    @IBAction func shape(sender: AnyObject) {
        shapeController.beginShape()
        showPinsInShape()
        shapeModal?.slideDownFromTop(self.view)
    }
    
    @IBAction func friends(sender: AnyObject) {
        shareController.editFriends()
    }
    
    func createGroupMode() {
        shapeModal?.slideDownFromTop(self.view)
        
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
            zoomController.photos = photoAlbum.photos(pin.memory!)
            self.navigationController?.pushViewController(zoomController, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        var delaySeconds = 0.0
        
        ensureUserKnown()
        
        memoryAlbum.downloadNewShares(user, callback: {memory in
            let color = CategoryController.getColorForCategory(memory.type)
            let title = "New " + memory.type + " from " + memory.originator
            self.delay(delaySeconds) {
                self.showMessage(title, color: color, time: 3)
            }
            
            delaySeconds += 2
        })
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    private func ensureUserKnown() {
        if (!user.hasName()) {
            newUserLabel.text = "Your sharing name"
            newUserText.becomeFirstResponder()
            newUserText.text = ""
            newUserModal?.slideOutFromRight(self.view)
        }
    }
    
    func showMessage(text: String, color: UIColor, time: Double) {
        let messageModal = Modal(viewName: "MessageView", owner: self)
        let message = messageModal.findElementByTag(1) as! UIButton
        message.backgroundColor = color
        message.setTitle(text, forState: UIControlState.Normal)
        messageModal.slideDownFromTop(self.view)
        
        delay(time) {
            messageModal.slideUpFromTop(self.view)
        }
    }

    func dismissMessage(sender: AnyObject?) {
        let messageModal = messageModals.removeLast()
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
        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: "foundTap:")
        map.addGestureRecognizer(tapRecognizer)
        map.showsPointsOfInterest = false
        map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
    }
    
    // User clicked on map - Add a memory there
    func foundTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Began) {
            let point = recognizer.locationInView(self.map)
            let tapPoint = self.map.convertPoint(point, toCoordinateFromView: self.view)
            self.addMemory.add(self, location: tapPoint)
        }
    }

    // Callback for location updates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        here = locations[0]
    }

    // Callback for button on the UI
    func addMemoryHere(type: String, id: String, description: String, location: CLLocationCoordinate2D?, orientation: UIDeviceOrientation?) {
        let actualLocation = location == nil ? here.coordinate : location!
        let memory = Memory(id: id, type: type, description: description, location: actualLocation, user: user, orientation: orientation)
        memoryAlbum.add(memory)
    }
    
    // Callback for button on the callout
    func deleteMemory(pin: MapPinView) {
        memoryAlbum.delete(pin)
    }

    // Callback for button on the callout
    func updateMemory(pin: MapPinView) {
        map!.removeAnnotation(pin.annotation!)
        map!.addAnnotation((pin.memory?.asMapPin())!)
        memoryAlbum.save()
    }
    
    // Callback for button on the callout
    func rewordMemory(pin: MapPinView) {
        map.deselectAnnotation(pin.annotation, animated: false)
        pin.refresh()
        addMemory.reword(self, memory: pin.memory!)
    }

    // Callback for display pins on map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MapPin) {
            let pinData = annotation as! MapPin
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as! MapPinView!
        
            if (pinView == nil) {
                let imageUrl = photoAlbum.getImagePath(pinData.memory.id)
                pinView = MapPinView(memoriesController: self, memory: pinData.memory, imageUrl: imageUrl)
            }
        
            return pinView
        } else if (annotation is ShapeCorner) {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("corner") as! ShapeCornerView!
            
            if (pinView == nil) {
                pinView = ShapeCornerView(memoriesController: self)
            }
            
            pinView.setSelected(true, animated: true)
            
            return pinView
            
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Starting {
            view.dragState = MKAnnotationViewDragState.Dragging
        } else if newState == MKAnnotationViewDragState.Ending || newState == MKAnnotationViewDragState.Canceling {
            view.dragState = MKAnnotationViewDragState.None;
            if (view.annotation is MapPin) {
                let pinData = view.annotation as! MapPin
                pinData.setCoordinate2(pinData.coordinate)
                self.memoryAlbum.save()
            } else if (view.annotation is ShapeCorner) {
                let pinData = view.annotation as! ShapeCorner
                shapeController.move(pinData)
                showPinsInShape()
            }
        }
    }
    
    func showPinsInShape() {
        let allPins = map.annotations
        for pin in allPins {
            if (pin is MapPin) {
                let mapPin = pin as! MapPin
                let pinView = map.viewForAnnotation(mapPin) as? MapPinView
                if (pinView != nil) {
                    pinView!.refreshImage()
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.2)
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }
    
    // Callback for new friend dialogs
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        textView.text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        if (text == "\n" && !textView.text.isEmpty) {
            if (textView == self.searchText) {
                print("SEARCH TEXT \(textView.text)")
                searchModal?.slideInFromLeft(self.view)
                searchText.resignFirstResponder()
                
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(textView.text, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                    if let placemark = placemarks?[0] {
                        self.map.setCenterCoordinate(placemark.location!.coordinate, animated: true)
                    }
                })
            } else {
                print("NEW USER TEXT \(textView.text)")
                
                newUserModal?.slideInFromRight(self.view)
                
                if (!user.hasName()) {
                    user.setName(textView.text)
                    newUserText.resignFirstResponder()
                } else {
                    user.addFriend(textView.text)
                    newUserText.resignFirstResponder()
                    shareController.shareWith(textView.text)
                }
            }
            
            return false
        }
        return true
        
    }
}

