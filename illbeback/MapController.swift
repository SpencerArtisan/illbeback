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
    @IBOutlet weak var backupButton: UIButton!
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
    var messageControlller: MessageController!
    var hintControlller: HintController!
    var backup: Backup?
    
    var newUserModal: Modal?
    var searchModal: Modal?
    var shapeModal: Modal?

    let queue = dispatch_queue_create("com.artisan.cachequeue", DISPATCH_QUEUE_CONCURRENT);
    var newUserLabel: UILabel!
    var newUserText: UITextView!
    var lastTimeAppUsed: NSDate?
    
    var flagRenderer: FlagRenderer!
    var flagRepository: FlagRepository!
    var outBox: OutBox!
    var inBox: InBox!
    
    func getView() -> UIView {
        return self.view
    }
    
    @IBAction func showNewStuff(sender: AnyObject) {
        flagListController.showFlags()
    }
    
    @IBAction func showEvents(sender: AnyObject) {
        eventListController.showEvents()
    }
    
    @IBAction func backup(sender: AnyObject) {
        backup!.create()
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

        shareController.shareFlag(sharing)
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
        self.messageControlller = MessageController(mapController: self)
        self.hintControlller = HintController(mapController: self)
        self.outBox = OutBox(flagRepository: flagRepository, photoAlbum: photoAlbum)
        self.inBox = InBox(flagRepository: flagRepository, photoAlbum: photoAlbum)
        self.backup = Backup(mapController: self, flagRepository: flagRepository, photoAlbum: photoAlbum)

        self.newUserLabel = newUserModal!.findElementByTag(1) as! UILabel!
        self.newUserText = newUserModal!.findElementByTag(2) as! UITextView!
        self.newUserText.delegate = self
        self.searchText.delegate = self
  
        updateButtonStates()
        flagRepository.read()
        photoAlbum.purge(flagRepository)
        
        Utils.addObserver(self, selector: "onFlagReceiveSuccess:", event: "FlagReceiveSuccess")
        Utils.addObserver(self, selector: "onAcceptSuccess:", event: "AcceptSuccess")
        Utils.addObserver(self, selector: "onDeclining:", event: "Declining")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        ensureUserKnown()
        
        if flagRepository.flags().count > 4 && !Preferences.hintedBackups() {
            hintControlller.backupHint()
            Preferences.hintedBackups(true)
        }
        
        if lastTimeAppUsed == nil || NSDate().timeIntervalSinceDate(lastTimeAppUsed!) > HOUR * 5 {
            updatePins()
            checkForImminentEvents()
            if flagRepository.flags().count == 0 && hintControlller != nil && Global.userDefined() {
                hintControlller.photoHint()
            }
        }
        
        if flagRepository.flags().count == 1 && !Preferences.hintedPressMap() && hintControlller != nil {
            hintControlller.dismissHint()
            Utils.delay(3) {
                self.hintControlller.pressMapHint()
            }
            Preferences.hintedPressMap(true)
        }
        
        inBox.receive()
        outBox.send()
        updateButtonStates()
        
        self.lastTimeAppUsed = NSDate()
    }

    func handleOpenURL(url: NSURL) {
        backup!.importFromURL(url)
    }
    
    func onFlagReceiveSuccess(note: NSNotification) {
        updateButtonStates()
    }
    
    func onAcceptSuccess(note: NSNotification) {
        updateButtonStates()
    }
    
    func onDeclining(note: NSNotification) {
        updateButtonStates()
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
    
    func ensureUserKnown() {
        if (!Global.userDefined()) {
            newUserLabel.text = "Your sharing name"
            newUserText.becomeFirstResponder()
            newUserText.text = ""
            newUserModal?.slideOutFromRight(self.view)
            hintControlller.sharingNameHint()
        }
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
        let actualLocation = location == nil ? (here == nil ? map.centerCoordinate : here.coordinate) : location!
        let flag = Flag.create(id, type: type, description: description, location: actualLocation, originator: Global.getUser().getName(), orientation: orientation, when: when)
        flagRepository.add(flag)
        updateButtonStates()
    }
    
    // Callback for button on the callout
    func deleteFlag(pin: MapPinView) {
        flagRepository.remove(pin.flag!)
    }
    
    func removePin(pin: MapPinView) {
        Utils.runOnUiThread {
            if pin.annotation != nil {
                self.map.removeAnnotation(pin.annotation!)
            }
        }
    }
    
    private func updateButtonStates() {
        alarmButton.hidden = flagRepository.events().count == 0
        newButton.hidden = flagRepository.new().count == 0
        backupButton.hidden = flagRepository.flags().count <= 4
    }
    
    func acceptRecentShare(flag: Flag) {
        photoAlbum.acceptRecentShare(flag)
        flag.accepting(Global.getUser().getName())
        outBox.send()
    }

    func declineRecentShare(flag: Flag) {
        flag.declining(Global.getUser().getName())
        outBox.send()
    }

    func shareFlag(pin: MapPinView) {
        shareController.shareFlag([pin])
    }
    
    // Callback for button on the callout
    func rewordFlag(pin: MapPinView) {
        deselect(pin)
        addFlag.reword(self, pin: pin)
    }
    
    // Callback for button on the callout
    func rescheduleFlag(pin: MapPinView) {
        deselect(pin)
        addFlag.reschedule(self, pin: pin)
    }
    
    // Callback for button on the callout
    func unblankFlag(pin: MapPinView) {
        deselect(pin)
        addFlag.unblank(self, pin: pin)
    }
    
    private func deselect(pin: MapPinView) {
        print("Deselect pin")
        map.deselectAnnotation(pin.annotation, animated: false)
        pin.refresh()
    }
    
    // Callback for display pins on map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return flagRenderer.render(mapView, viewForAnnotation: annotation)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Starting {
            view.dragState = MKAnnotationViewDragState.Dragging
        } else if newState == MKAnnotationViewDragState.Ending || newState == MKAnnotationViewDragState.Canceling {
            view.dragState = MKAnnotationViewDragState.None;
            if view.annotation is MapPin {
                let pinData = view.annotation as! MapPin
                pinData.setCoordinate2(pinData.coordinate)
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
                    hintControlller.dismissHint()
                    Utils.delay(2) {
                        self.hintControlller.photoHint()
                    }
                } else {
                    Global.getUser().addFriend(textView.text)
                    Preferences.user(Global.getUser())
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

