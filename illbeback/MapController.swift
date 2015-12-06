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


class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate {
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
    var addFlag: AddFlagController!
    var rephotoController: RephotoController!
    var rememberController: RememberController!
    var zoomController: ZoomSwipeController!
    var shareController: ShareController!
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
    
    var flagRenderer: FlagRenderer!
    var flagRepository: FlagRepository!
    var outBox: OutBox!
    
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
        var sharing:[MapPinView] = []
        
        let allPins = map.annotations
        for pin in allPins {
            if (pin is MapPin) {
                let mapPin = pin as! MapPin
                if !mapPin.flag.isBlank() && shapeController.shapeContains(mapPin.flag.location()) {
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
        
        self.flagRepository = FlagRepository()
        self.flagRenderer = FlagRenderer(map: map, mapController: self)

        self.newUserModal = Modal(viewName: "NewUser", owner: self)
        self.searchModal = Modal(viewName: "SearchView", owner: self)
        self.shapeModal = Modal(viewName: "ShapeOptions", owner: self)
        self.addFlag = AddFlagController(album: photoAlbum, mapController: self)
        self.eventListController = EventsController(mapController: self)
        self.flagListController = FlagsController(mapController: self)
        self.rephotoController = RephotoController(photoAlbum: photoAlbum, flagRepository: flagRepository)
        self.rememberController = RememberController(album: photoAlbum, mapController: self)
        self.zoomController = ZoomSwipeController()
        self.shapeController = ShapeController(map: map, mapController: self)
        self.shareController = ShareController(mapController: self)
        self.outBox = OutBox(flagRepository: flagRepository, photoAlbum: photoAlbum)

        self.newUserLabel = newUserModal!.findElementByTag(1) as! UILabel!
        self.newUserText = newUserModal!.findElementByTag(2) as! UITextView!
        self.newUserText.delegate = self
        self.searchText.delegate = self
  
        updateButtonStates()
        
        flagRepository.read()
   
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
        shareController.editFriends()
    }
    
    // Callback for button on the callout
    func rephotoMemory(pin: MapPinView) {
        if (self.navigationController?.topViewController != rephotoController) {
            zoomController.mapController = self
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
            zoomController.mapController = self
            zoomController.pinToRephoto = pin
            self.navigationController?.pushViewController(zoomController, animated: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        ensureUserKnown()
        
        if lastTimeAppUsed == nil || NSDate().timeIntervalSinceDate(lastTimeAppUsed!) > HOUR * 5 {
            updatePins()
            checkForImminentEvents()
        }
        
        downloadNewShares()
        updateButtonStates()
        
        self.lastTimeAppUsed = NSDate()
    }
    
    private func downloadNewShares() {
        InBox(flagRepository: flagRepository, photoAlbum: photoAlbum).receive()
    }
    
    private func checkForImminentEvents() {
        let imminentEvents = flagRepository.imminentEvents()
        if imminentEvents.count > 0 && imminentEvents[0].daysToGo() < 2 {
            eventListController.showEvents()
        }
    }
    
    private func updatePins() {
        flagRepository.purge()
        flagRenderer.updateEventPins(flagRepository.events())
    }
    
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
    
    // User clicked on map - Add a flag there
    func foundTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            let point = recognizer.locationInView(self.map)
            let tapPoint = self.map.convertPoint(point, toCoordinateFromView: self.view)
            self.addFlag.add(self, location: tapPoint)
        }
    }

    // Callback for location updates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        here = locations[0]
    }

    // Callback for button on the UI
    func addFlagHere(type: String, id: String, description: String, location: CLLocationCoordinate2D?, orientation: UIDeviceOrientation?, when: NSDate?) {
        let actualLocation = location == nil ? here.coordinate : location!
        let flag = Flag.create(id, type: type, description: description, location: actualLocation, originator: Global.getUser().getName(), orientation: orientation, when: when)
        flagRepository.add(flag)
        updateButtonStates()
    }
    
    // Callback for button on the callout
    func deleteMemory(pin: MapPinView) {
        flagRepository.remove(pin.flag!)
    }
    
    func removePin(pin: MapPinView) {
        Utils.runOnUiThread2 {
            if pin.annotation != nil {
                self.map.removeAnnotation(pin.annotation!)
            }
        }
    }
    
    private func updateButtonStates() {
        alarmButton.hidden = flagRepository.events().count == 0
        newButton.hidden = flagRepository.new().count == 0
    }
    
    func acceptRecentShare(flag: Flag) {
        do {
            if flag.state() == .ReceivedNew {
                try flag.acceptNew()
            } else {
                try flag.acceptUpdate()
            }
            photoAlbum.acceptRecentShare(flag)
        } catch {
            flag.reset(FlagState.ReceivedNew)
        }
        updateButtonStates()
        outBox.send()
    }

    func declineRecentShare(flag: Flag) {
        do {
            if flag.state() == .ReceivedNew {
                try flag.declineNew()
            } else {
                try flag.declineUpdate()
            }
        } catch {
            flag.reset(FlagState.ReceivedNew)
        }
        updateButtonStates()
        outBox.send()
    }

    func shareMemory(pin: MapPinView) {
        shareController.shareMemory([pin])
    }
    
    // Callback for button on the callout
    func rewordMemory(pin: MapPinView) {
        deselect(pin)
        addFlag.reword(self, pin: pin)
    }
    
    // Callback for button on the callout
    func rescheduleMemory(pin: MapPinView) {
        deselect(pin)
        addFlag.reschedule(self, pin: pin)
    }
    
    // Callback for button on the callout
    func unblankMemory(pin: MapPinView) {
        deselect(pin)
        addFlag.unblank(self, pin: pin)
    }
    
    private func deselect(pin: MapPinView) {
        map.deselectAnnotation(pin.annotation, animated: false)
        pin.refresh()
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
            if view.annotation is MapPin {
                let pinData = view.annotation as! MapPin
                pinData.setCoordinate2(pinData.coordinate)
                self.flagRepository.save()
            } else if view.annotation is ShapeCorner {
                let pinData = view.annotation as! ShapeCorner
                shapeController.move(pinData)
                showPinsInShape()
            }
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for aView in views {
            if aView is MapPinView {
                if (aView as! MapPinView).flag!.isEvent() {
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
            if (view as! MapPinView).flag!.isEvent() {
                view.layer.zPosition = 1
            }
        }
    }
    
    func showPinsInShape() {
        let allPins = map.annotations
        for pin in allPins {
            if pin is MapPin {
                let mapPin = pin as! MapPin
                let pinView = map.viewForAnnotation(mapPin) as? MapPinView
                pinView?.refreshImage()
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
        
        if textView == self.newUserText && text != "\n" {
            if textView.text.characters.count + text.characters.count > 14 { return false }
        }
        
        if text == "\n" && !textView.text.isEmpty {
            if textView == self.searchText {
                print("SEARCH TEXT \(textView.text)")
                searchModal?.slideInFromLeft(self.view)
                searchText.resignFirstResponder()
                
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(textView.text, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                    if let placemark = placemarks?[0] {
                        self.centerMap(placemark.location!.coordinate)
                        self.addFlag.addBlank(self, location: placemark.location!.coordinate, description: textView.text)
                    }
                })
            } else {
                print("NEW USER TEXT \(textView.text)")
                
                newUserModal?.slideInFromRight(self.view)
                
                if !Global.userDefined() {
                    Global.setUserName(textView.text)
                } else {
                    Global.getUser().addFriend(textView.text)
                    shareController.shareWith(textView.text)
                }
                newUserText.resignFirstResponder()
            }
            
            return false
        }
        return true
    }
    
    func centerMap(at: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.016, longitudeDelta: 0.016)
        let region = MKCoordinateRegion(center: at, span: span)
        map.setRegion(region, animated: true)
    }
}

