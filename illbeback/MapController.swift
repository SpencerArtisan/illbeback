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

    let queue = DispatchQueue(label: "com.artisan.cachequeue", attributes: DispatchQueue.Attributes.concurrent);
    var newUserLabel: UILabel!
    var newUserText: UITextView!
    var lastTimeAppUsed: Date?
    
    var flagRenderer: FlagRenderer!
    var flagRepository: FlagRepository!
    var outBox: OutBox!
    var inBox: InBox!
    
    func getView() -> UIView {
        return self.view
    }
    
    @IBAction func showNewStuff(_ sender: AnyObject) {
        flagListController.showFlags()
    }
    
    @IBAction func showEvents(_ sender: AnyObject) {
        eventListController.showEvents()
    }
    
    @IBAction func backup(_ sender: AnyObject) {
        backup!.create()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        shapeController.clear()
        showPinsInShape()
        shapeModal?.slideUpFromTop(view)
    }
    
    @IBAction func share(_ sender: AnyObject) {
        var sharing:[FlagAnnotationView] = []
        
        let allPins = map.annotations
        for pin in allPins {
            if (pin is FlagAnnotation) {
                let flagAnnotation = pin as! FlagAnnotation
                if !flagAnnotation.flag.isBlank() && shapeController.shapeContains(flagAnnotation.flag.location()) {
                    let pinView = map.view(for: flagAnnotation) as! FlagAnnotationView
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

        let element1 = newUserModal!.findElementByTag(1)
        self.newUserLabel = element1 as! UILabel?
        let element2 = newUserModal!.findElementByTag(2)
        self.newUserText = element2 as! UITextView?
        self.newUserText.delegate = self
        self.searchText.delegate = self
  
        updateButtonStates()
        flagRepository.read()
        photoAlbum.purge(flagRepository)
        
        Utils.addObserver(self, selector: #selector(MapController.onFlagReceiveSuccess), event: "FlagReceiveSuccess")
        Utils.addObserver(self, selector: #selector(MapController.onAcceptSuccess), event: "AcceptSuccess")
        Utils.addObserver(self, selector: #selector(MapController.onDeclineSuccess), event: "DeclineSuccess")
        Utils.addObserver(self, selector: #selector(MapController.onDeclining), event: "Declining")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        ensureUserKnown()
        
        if lastTimeAppUsed == nil || Date().timeIntervalSince(lastTimeAppUsed!) > HOUR * 5 {
            flagRepository.purge()
            updatePins()
            checkForImminentEvents()
        }
        
        if flagRepository.flags().count == 1 && !Preferences.hintedFirstFlag() && hintControlller != nil {
            Preferences.hintedFirstFlag(true)
            hintControlller.dismissHint()
            Utils.delay(3) {
                self.hintControlller.firstFlagHint()
            }
        }
        
        if flagRepository.flags().count == 2 && !Preferences.hintedPressMap() && hintControlller != nil {
            Preferences.hintedPressMap(true)
            hintControlller.dismissHint()
            Utils.delay(3) {
                self.hintControlller.pressMapHint()
            }
        }
        
        inBox.receive()
        outBox.send()
        updateButtonStates()
        
        self.lastTimeAppUsed = Date()
    }

    func handleOpenURL(_ url: URL) {
        backup!.importFromURL(url)
    }
    
    @objc func onFlagReceiveSuccess(_ note: Notification) {
        updateButtonStates()
    }
    
    @objc func onAcceptSuccess(_ note: Notification) {
        updateButtonStates()
        
    }
    
    @objc func onDeclineSuccess(_ note: Notification) {
        updateButtonStates()
    }
    
    @objc func onDeclining(_ note: Notification) {
        updateButtonStates()
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(rememberController, animated: false)
    }
    
    @IBAction func currentLocation(_ sender: AnyObject) {
        if here != nil {
            centerMap(here!.coordinate)
        }
    }
    
    @IBAction func search(_ sender: AnyObject) {
        searchText.becomeFirstResponder()
        searchText.text = ""
        searchModal?.slideOutFromLeft(self.view)
    }
    
    @IBAction func cancelSearch(_ sender: AnyObject) {
        searchModal?.slideInFromLeft(self.view)
        searchText.resignFirstResponder()
    }
    
    @IBAction func shape(_ sender: AnyObject) {
        shapeController.beginShape()
        showPinsInShape()
        shapeModal?.blurBackground()
        shapeModal?.slideDownFromTop(self.view)
    }
    
    @IBAction func friends(_ sender: AnyObject) {
        shareController.editFriends()
    }
    
    // Callback for button on the callout
    func rephotoMemory(_ pin: FlagAnnotationView) {
        if (self.navigationController?.topViewController != rephotoController) {
            zoomController.mapController = self
            zoomController.pinToRephoto = pin
            rephotoController.pinToRephoto = pin
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(zoomController, animated: false)
            self.navigationController?.pushViewController(rephotoController!, animated: false)
        }
    }
    
    // Callback for button on the callout
    func zoomPicture(_ pin: FlagAnnotationView) {
        if (self.navigationController?.topViewController != zoomController) {
            self.navigationController?.isNavigationBarHidden = true
            zoomController.mapController = self
            zoomController.pinToRephoto = pin
            self.navigationController?.pushViewController(zoomController, animated: true)
        }
    }

    
    fileprivate func checkForImminentEvents() {
        let imminentEvents = flagRepository.imminentEvents()
        if imminentEvents.count > 0 && imminentEvents[0].daysToGo() < 2 {
            eventListController.showEvents()
        }
    }
    
    fileprivate func updatePins() {
        flagRepository.purge()
        flagRenderer.updateEventPins(flagRepository.events())
    }
    
    func ensureUserKnown() {
        if (!Global.userDefined()) {
            newUserLabel.text = "Your username"
            newUserText.becomeFirstResponder()
            newUserText.text = ""
            newUserModal?.slideOutFromRight(self.view)
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
        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapController.foundTap(_:)))
        map.addGestureRecognizer(tapRecognizer)
        map.showsPointsOfInterest = false
        map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    // User clicked on map - Add a flag there
    @objc func foundTap(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.began {
            let point = recognizer.location(in: self.map)
            let tapPoint = self.map.convert(point, toCoordinateFrom: self.view)
            self.addFlag.add(self, location: tapPoint)
        }
    }

    // Callback for location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        here = locations[0]
    }

    // Callback for button on the UI
    func addFlagHere(_ type: String, id: String, description: String, location: CLLocationCoordinate2D?, orientation: UIDeviceOrientation?, when: Date?) {
        let actualLocation = location == nil ? (here == nil ? map.centerCoordinate : here.coordinate) : location!
        let flag = Flag.create(id, type: type, description: description, location: actualLocation, originator: Global.getUser().getName(), orientation: orientation, when: when)
        flagRepository.create(flag)
        updateButtonStates()
    }
    
    // Callback for button on the callout
    func deleteFlag(_ pin: FlagAnnotationView) {
        flagRepository.remove(pin.flag!)
    }
    
    func removePin(_ pin: FlagAnnotationView) {
        Utils.runOnUiThread {
            if pin.annotation != nil {
                self.map.removeAnnotation(pin.annotation!)
            }
        }
    }
    
    fileprivate func updateButtonStates() {
        alarmButton.isHidden = flagRepository.events().count == 0
        newButton.isHidden = flagRepository.new().count == 0
        backupButton.isHidden = flagRepository.flags().count <= 4
        if flagRepository.flags().count > 4 && !Preferences.hintedBackups() && !inBox.isReceiving() {
            Preferences.hintedBackups(true)
            Utils.delay(2) {
                self.hintControlller.backupHint()
            }
        }
    }
    
    func acceptRecentShare(_ flag: Flag) {
        flag.accepting(Global.getUser().getName())
        outBox.send()
    }

    func declineRecentShare(_ flag: Flag) {
        flag.declining(Global.getUser().getName())
        outBox.send()
    }

    func shareFlag(_ pin: FlagAnnotationView) {
        shareController.shareFlag([pin])
    }
    
    // Callback for button on the callout
    func rewordFlag(_ pin: FlagAnnotationView) {
        addFlag.reword(self, pin: pin)
    }
    
    // Callback for button on the callout
    func rescheduleFlag(_ pin: FlagAnnotationView) {
        addFlag.reschedule(self, pin: pin)
    }
    
    // Callback for button on the callout
    func unblankFlag(_ pin: FlagAnnotationView) {
        addFlag.unblank(self, pin: pin)
        pin.refreshImage()
    }
    
    // Callback for display pins on map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return flagRenderer.render(mapView, viewForAnnotation: annotation)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == MKAnnotationView.DragState.starting {
            view.dragState = MKAnnotationView.DragState.dragging
        } else if newState == MKAnnotationView.DragState.ending || newState == MKAnnotationView.DragState.canceling {
            view.dragState = MKAnnotationView.DragState.none;
            if view.annotation is FlagAnnotation {
                let pinData = view.annotation as! FlagAnnotation
                pinData.setCoordinate2(pinData.coordinate)
            } else if view.annotation is ShapeCorner {
                let pinData = view.annotation as! ShapeCorner
                shapeController.move(pinData)
                showPinsInShape()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for aView in views {
            if aView is FlagAnnotationView {
                if (aView as! FlagAnnotationView).flag!.isEvent() {
                    aView.layer.zPosition = 1
                }
            } 
        }
    }
  
    func showPinsInShape() {
        let allPins = map.annotations
        for pin in allPins {
            if pin is FlagAnnotation {
                let flagAnnotation = pin as! FlagAnnotation
                let pinView = map.view(for: flagAnnotation) as? FlagAnnotationView
                pinView?.refreshImage()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.2)
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    // Callback for new friend dialogs
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.text = textView.text.trimmingCharacters(in: CharacterSet.newlines)
        
        if textView == self.newUserText && text != "\n" {
            if textView.text.count + text.count > 14 { return false }
        }
        
        if text == "\n" && !textView.text.isEmpty {
            if textView == self.searchText {
                print("SEARCH TEXT \(String(describing: textView.text))")
                searchModal?.slideInFromLeft(self.view)
                searchText.resignFirstResponder()
                
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString(textView.text) { placemarks, error in
                    if let placemark = placemarks?[0] {
                        self.centerMap(placemark.location!.coordinate)
                        self.addFlag.addBlank(self, location: placemark.location!.coordinate, description: textView.text)
                    }
                }
            } else {
                print("NEW USER TEXT \(String(describing: textView.text))")
                
                newUserModal?.slideInFromRight(self.view)
                
                if !Global.userDefined() {
                    Global.setUserName(textView.text, allowOverwrite: false)
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
    
    func centerMap(_ at: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.016, longitudeDelta: 0.016)
        let region = MKCoordinateRegion(center: at, span: span)
        map.setRegion(region, animated: true)
    }
}

