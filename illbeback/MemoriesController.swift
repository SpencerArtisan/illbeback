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
    let HOUR: Double = 60 * 60
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var sharingName: UITextView!
    @IBOutlet weak var searchText: UITextView!
    
    var locationManager = CLLocationManager()
    var here: CLLocation!
    let photoAlbum = PhotoAlbum()
    
    var shapeController: ShapeController!
    var addMemory: AddMemoryController!
    var rephotoController: RephotoController!
    var rememberController: RememberController!
    var zoomController: ZoomSwipeController!
//    var shareController: ShareController!
    var eventListController: EventsController!
    var flagListController: FlagsController!

    var newUserModal: Modal?
    var searchModal: Modal?
    var shapeModal: Modal?

    var messageModals: [Modal] = []
    let queue = dispatch_queue_create("com.artisan.cachequeue", DISPATCH_QUEUE_CONCURRENT);
    var downloadingMessages = [String:Modal]()
    var newUserLabel: UILabel!
    var newUserText: UITextView!
    var lastTimeAppUsed: NSDate?
    
    // NEW WORLD
    var flagRenderer: FlagRenderer!
    var flagRepository: FlagRepository!
    
    func getView() -> UIView {
        return self.view
    }
    
    @IBAction func showNewStuff(sender: AnyObject) {
        flagListController.showFlags()
    }
    
    @IBAction func showEvents(sender: AnyObject) {
        eventListController.showEvents()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        shapeController.clear()
        showPinsInShape()
        shapeModal?.slideUpFromTop(view)
    }
    
    @IBAction func share(sender: AnyObject) {
//        var sharing:[MapPinView] = []
//        
//        let allPins = map.annotations
//        for pin in allPins {
//            if (pin is MapPin) {
//                let mapPin = pin as! MapPin
//                if shapeController.shapeContains(mapPin.memory.location) {
//                    let pinView = map.viewForAnnotation(mapPin) as! MapPinView
//                    sharing.append(pinView)
//                }
//            }
//        }
//
//        shareController.shareMemory(sharing)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        initMap()
        
        self.flagRepository = FlagRepository()
        self.flagRenderer = FlagRenderer(map: map, memoriesController: self)

        self.newUserModal = Modal(viewName: "NewUser", owner: self)
        self.searchModal = Modal(viewName: "SearchView", owner: self)
        self.shapeModal = Modal(viewName: "ShapeOptions", owner: self)
        self.addMemory = AddMemoryController(album: photoAlbum, memoriesViewController: self)
        self.eventListController = EventsController(memoriesViewController: self)
        self.flagListController = FlagsController(memoriesViewController: self)
        self.rephotoController = RephotoController(photoAlbum: photoAlbum, flagRepository: flagRepository)
        self.rememberController = RememberController(album: photoAlbum, memoriesController: self)
        self.zoomController = ZoomSwipeController()
        self.shapeController = ShapeController(map: map, memories: self)
//        self.shareController = ShareController(memories: self)

        self.newUserLabel = newUserModal!.findElementByTag(1) as! UILabel!
        self.newUserText = newUserModal!.findElementByTag(2) as! UITextView!
        self.newUserText.delegate = self
        self.searchText.delegate = self
  
        updateButtonStates()
        self.flagRenderer.add(flagRepository.flags())
   
        Utils.addObserver(self, selector: "nameTaken:", event: "NameTaken")
        Utils.addObserver(self, selector: "nameAccepted:", event: "NameAccepted")
        Utils.addObserver(self, selector: "eventListChange:", event: "EventListChange")
    }
    
    func nameTaken(note: NSNotification) {
        let takenName = note.userInfo!["name"]
        self.showMessage("Sharing name \(takenName!) taken!", color: UIColor.redColor(), fontColor: UIColor.whiteColor(), time: 3.0)
        ensureUserKnown()
    }
    
    func nameAccepted(note: NSNotification) {
        let name = note.userInfo!["name"]
        self.showMessage("Weclome to Backmap \(name!)", color: UIColor.greenColor(), fontColor: UIColor.blackColor(), time: 3.0)
    }
    
    func eventListChange(note: NSNotification) {
        let enable = note.userInfo!["enable"] as! Bool
        self.alarmButton.hidden = !enable
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.pushViewController(rememberController, animated: false)
    }
    
    @IBAction func currentLocation(sender: AnyObject) {
        if here != nil {
            centerMap(here!.coordinate)
        }
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
//        shareController.editFriends()
    }
    
    // Callback for button on the callout
    func rephotoMemory(pin: MapPinView) {
        if (self.navigationController?.topViewController != rephotoController) {
            zoomController.memoriesController = self
            zoomController.pinToRephoto = pin
            rephotoController.pinToRephoto = pin
            self.navigationController?.navigationBarHidden = true
            self.navigationController?.pushViewController(zoomController, animated: false)
            self.navigationController?.pushViewController(rephotoController!, animated: false)
        }
    }
    
    // Callback for button on the callout
    func zoomPicture(pin: MapPinView) {
        if (self.navigationController?.topViewController != zoomController) {
            self.navigationController?.navigationBarHidden = true
            zoomController.memoriesController = self
            zoomController.pinToRephoto = pin
            self.navigationController?.pushViewController(zoomController, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        ensureUserKnown()
        
        if lastTimeAppUsed == nil || NSDate().timeIntervalSinceDate(lastTimeAppUsed!) > HOUR * 5 {
            updateEventPins()
            checkForImminentEvents()
        }
        
//        downloadNewShares()
        updateButtonStates()
        
        self.lastTimeAppUsed = NSDate()
    }
    
    func checkForImminentEvents() {
        let imminentEvents = flagRepository.imminentEvents()
        if imminentEvents.count > 0 && imminentEvents[0].daysToGo() < 2 {
            eventListController.showEvents()
        }
    }
    
    func updateEventPins() {
        flagRenderer.updateEventPins(flagRepository.events())
    }
    
//    func downloadNewShares() {
//        var delaySeconds1: Double = 0
//        var delaySeconds2: Double = 0
//        
//        for oldDownload in downloadingMessages.values {
//            oldDownload.slideUpFromTop(self.view)
//        }
//        downloadingMessages.removeAll()
//        
//        memoryAlbum.downloadNewShares(
//            {memory in
//                print("onStart callback for downloading \(memory.asString())")
//                let color = CategoryController.getColorForCategory(memory.type)
//                let title = "Downloading " + memory.type
//                self.delay(delaySeconds1) {
//                    let message = self.showMessage(title, color: color, time: nil)
//                    let oldModal = self.downloadingMessages[memory.id]
//                    if oldModal != nil {
//                        oldModal?.slideUpFromTop(self.view)
//                    }
//                    self.downloadingMessages[memory.id] = message
//                }
//                
//                delaySeconds1 += 1.5
//            },
//            onComplete: {memory in
//                let color = CategoryController.getColorForCategory(memory.type)
//                let title = "Downloaded " + memory.type + " from " + memory.originator
//                self.delay(delaySeconds2) {
//                    let downloadingMessage = self.downloadingMessages[memory.id]
//                    print("onComplete callback for downloading \(memory.asString()).  Will dismiss modal \(downloadingMessage) from outstanding modals \(self.downloadingMessages)")
//                    if downloadingMessage != nil {
//                        print("Dismissing modal")
//                        downloadingMessage?.slideUpFromTop(self.view)
//                    }
//                    self.showMessage(title, color: color, time: 2)
//                    self.updateButtonStates()
//                }
//                
//                delaySeconds2 += 1.5
//            },
//            onAckReceipt: {memory in
//                print("onAckReceipt callback for \(memory.asString())")
//                let pin = self.getPin(memory)
//                if pin != nil {
//                    self.map!.removeAnnotation(pin!)
//                    self.map!.addAnnotation(pin!)
//                }
//                let response = memory.isAccepted() ? "accepted" : "declined"
//                let color = CategoryController.getColorForCategory(memory.type)
//                let title = "\(memory.originator) \(response) \(memory.summary())"
//                self.delay(delaySeconds1) {
//                    self.showMessage(title, color: color, time: 2)
//                }
//                if memory.isAccepted() {
//                    self.memoryAlbum.inviteeAccepted(memory.originator, memoryId: memory.id)
//                } else {
//                    self.memoryAlbum.inviteeDeclined(memory.originator, memoryId: memory.id)
//                }
//                self.memoryAlbum.save()
//                
//                delaySeconds1 += 1.5
//            }
//        )
//    }

    private func ensureUserKnown() {
        if (!Global.userDefined()) {
            newUserLabel.text = "Your sharing name"
            newUserText.becomeFirstResponder()
            newUserText.text = ""
            newUserModal?.slideOutFromRight(self.view)
        }
    }
    
    func showMessage(text: String, color: UIColor, time: Double?) -> Modal {
        return showMessage(text, color: color, fontColor: UIColor.blackColor(), time: time)
    }
    
    func showMessage(text: String, color: UIColor, fontColor: UIColor, time: Double?) -> Modal {
        let messageModal = Modal(viewName: "MessageView", owner: self)
        let message = messageModal.findElementByTag(1) as! UIButton
        message.backgroundColor = color.colorWithAlphaComponent(1)
        message.setTitleColor(fontColor, forState: UIControlState.Normal)
        message.setTitle(text, forState: UIControlState.Normal)
        messageModal.slideDownFromTop(self.view)
        
        if time != nil {
            Utils.delay(time!) {
                messageModal.slideUpFromTop(self.view)
            }
        }
        return messageModal
    }

    func dismissMessage(messageModal: Modal) {
        messageModal.slideUpFromTop(self.view)
    }
    
    func dismissMessage(sender: AnyObject?) {
        let messageModal = messageModals.removeLast()
        messageModal.slideUpFromTop(self.view)
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
    func addMemoryHere(type: String, id: String, description: String, location: CLLocationCoordinate2D?, orientation: UIDeviceOrientation?, when: NSDate?) {
        let actualLocation = location == nil ? here.coordinate : location!
        let flag = Flag.create(id, type: type, description: description, location: actualLocation, originator: Global.getUser().getName(), orientation: orientation, when: when)
        flagRepository.add(flag)
        flagRenderer.add(flag)
        updateButtonStates()
    }
    
    func updateButtonStates() {
        alarmButton.hidden = flagRepository.events().count == 0
        newButton.hidden = flagRepository.new().count == 0
    }
    
    // Callback for button on the callout
    func deleteMemory(pin: MapPinView) {
        flagRepository.remove(pin.flag!)
        photoAlbum.delete(pin.flag!)
        flagRenderer.remove(pin)
    }
    
    func removePin(pin: MapPinView) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            if pin.annotation != nil {
                self.map.removeAnnotation(pin.annotation!)
            }
        }
    }
    
    func acceptRecentShare(flag: Flag) {
//        memory.accept()
//        memoryAlbum!.oldMemories[memory.id] = memory
//        memoryAlbum!.newMemories.removeValueForKey(memory.id)
//        photoAlbum.acceptRecentShare(memory)
//        if memory.isEvent() {
//            print("Accepting event")
//            shareController.acceptRecentShare(memory)
//            memory.resetState()
//        }
//        memoryAlbum!.save()
//        updateButtonStates()
    }

    func declineRecentShare(flag: Flag) {
//        memory.decline()
//        memoryAlbum!.newMemories.removeValueForKey(memory.id)
//
//        if memory.isEvent() {
//            print("Declining event")
//            shareController.declineRecentShare(memory)
//        }
//        let oldMemory = memoryAlbum!.oldMemories[memory.id]
//        if oldMemory != nil {
//            map!.addAnnotation(oldMemory!.asMapPin())
//        }
//        memoryAlbum!.save()
//        updateButtonStates()
    }

    func shareMemory(pin: MapPinView) {
//        shareController.shareMemory([pin])
//        memoryAlbum!.save()
    }

    // Callback for button on the callout
    func updateMemory(pin: MapPinView) {
        flagRenderer.update(pin)
        flagRepository.save()
    }
    
    // Callback for button on the callout
    func rewordMemory(pin: MapPinView) {
        map.deselectAnnotation(pin.annotation, animated: false)
        pin.refresh()
        addMemory.reword(self, pin: pin)
    }
    
    // Callback for button on the callout
    func rescheduleMemory(pin: MapPinView) {
        map.deselectAnnotation(pin.annotation, animated: false)
        pin.refresh()
        addMemory.reschedule(self, pin: pin)
    }
    
    // Callback for button on the callout
    func unblankMemory(pin: MapPinView) {
        map.deselectAnnotation(pin.annotation, animated: false)
        pin.refresh()
        addMemory.unblank(self, pin: pin)
    }
    
    // Callback for display pins on map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return flagRenderer.render(viewForAnnotation: annotation)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Starting {
            view.dragState = MKAnnotationViewDragState.Dragging
        } else if newState == MKAnnotationViewDragState.Ending || newState == MKAnnotationViewDragState.Canceling {
            view.dragState = MKAnnotationViewDragState.None;
            if (view.annotation is MapPin) {
                let pinData = view.annotation as! MapPin
                pinData.setCoordinate2(pinData.coordinate)
                self.flagRepository.save()
            } else if (view.annotation is ShapeCorner) {
                let pinData = view.annotation as! ShapeCorner
                shapeController.move(pinData)
                showPinsInShape()
            }
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
            for aView in views {
                if aView is MapPinView {
                    if (aView as! MapPinView).flag?.type() == "Event" {
                        aView.layer.zPosition = 1
                    }
                }
            }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
       view.layer.zPosition = 2
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        view.layer.zPosition = 0
        if view is MapPinView {
            if (view as! MapPinView).flag?.type() == "Event" {
                view.layer.zPosition = 1
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
        
        if (textView == self.newUserText && text != "\n") {
            if textView.text.characters.count + text.characters.count > 14 { return false }
        }
        
        if (text == "\n" && !textView.text.isEmpty) {
            if (textView == self.searchText) {
                print("SEARCH TEXT \(textView.text)")
                searchModal?.slideInFromLeft(self.view)
                searchText.resignFirstResponder()
                
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(textView.text, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                    if let placemark = placemarks?[0] {
                        self.centerMap(placemark.location!.coordinate)
                        self.addMemory.addBlank(self, location: placemark.location!.coordinate, description: textView.text)
                    }
                })
            } else {
                print("NEW USER TEXT \(textView.text)")
                
                newUserModal?.slideInFromRight(self.view)
                
                if (!Global.userDefined()) {
                    Global.setUserName(textView.text)
                    newUserText.resignFirstResponder()
                } else {
                    Global.getUser().addFriend(textView.text)
                    newUserText.resignFirstResponder()
//                    shareController.shareWith(textView.text)
                }
            }
            
            return false
        }
        return true
        
    }
    
    
    func centerMap(at: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.016, longitudeDelta: 0.016)
        let region = MKCoordinateRegion(center: at, span: span)
        self.map.setRegion(region, animated: true)

    }
}

