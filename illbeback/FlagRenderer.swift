//
//  FlagRenderer.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class FlagRenderer: NSObject {
    private let map: MKMapView
    private let mapController: MapController
    
    init(map: MKMapView, mapController: MapController) {
        self.map = map
        self.mapController = mapController
        super.init()
        Utils.addObserver(self, selector: "onFlagAdded:", event: "FlagAdded")
        Utils.addObserver(self, selector: "onFlagRemoved:", event: "FlagRemoved")
        Utils.addObserver(self, selector: "onFlagSent:", event: "FlagSent")
        Utils.addObserver(self, selector: "onFlagReceiveSuccess:", event: "FlagReceiveSuccess")
        Utils.addObserver(self, selector: "onFlagChanged:", event: "FlagChanged")
        Utils.addObserver(self, selector: "onAckReceiveSuccess:", event: "AckReceiveSuccess")
        Utils.addObserver(self, selector: "onAcceptSuccess:", event: "AcceptSuccess")
        Utils.addObserver(self, selector: "onDeclineSuccess:", event: "DeclineSuccess")
    }
    
    func render(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is FlagAnnotation {
            let pinData = annotation as! FlagAnnotation
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as! FlagAnnotationView!
            
            if pinView == nil {
                pinView = FlagAnnotationView(mapController: mapController, flag: pinData.flag)
            }
            
            return pinView
        } else if annotation is ShapeCorner {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("corner") as! ShapeCornerView!
            
            if pinView == nil {
                pinView = ShapeCornerView(mapController: mapController)
            }
            
            pinView.selected = true

            return pinView
        }
        return nil
    }

    func onAcceptSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        refreshImage(flag)
    }
    
    func onDeclineSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        refreshImage(flag)
    }
    
    func onFlagChanged(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        refresh(flag)
    }
    
    func onFlagAdded(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        add(flag)
    }

    func onFlagRemoved(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        remove(flag)
    }
    
    func onFlagSent(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        refresh(flag)
    }
    
    func onFlagReceiveSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        refresh(flag)
    }
    
    func onAckReceiveSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        refresh(flag)
    }
    
    func add(flag: Flag) {
        Utils.runOnUiThread {
            let pin = self.createPin(flag)
            self.map.addAnnotation(pin)
        }
    }
    
    func remove(pin: FlagAnnotationView) {
        map.removeAnnotation(pin.annotation!)
    }
    
    func remove(flag: Flag) {
        let pin = getPin(flag)
        if pin != nil {
            print("Removed pin for \(flag.type())")
            map.removeAnnotation(pin!)
        }
    }
    
    func update(pin: FlagAnnotationView) {
        print("Replace pin")
        map.removeAnnotation(pin.annotation!)
        map.addAnnotation(createPin(pin.flag!))
    }
    
    func refresh(pin: FlagAnnotationView) {
        pin.refresh()
    }

    func refresh(flag: Flag) {
        Utils.runOnUiThread {
            if let pin = self.getPinView(flag) {
                self.refresh(pin)
            }
        }
    }
    
    
    func refreshImage(flag: Flag) {
        if let pin = getPinView(flag) {
            pin.refreshImage()
        }
    }
    
    func updateEventPins(events: [Flag]) {
        for event in events {
            refreshImage(event)
        }
    }
    
    func getPin(flag: Flag) -> FlagAnnotation? {
        for pin in self.map.annotations {
            if pin is FlagAnnotation && (pin as! FlagAnnotation).flag.id() == flag.id() {
                let flagAnnotation = pin as? FlagAnnotation
                return flagAnnotation
            }
        }
        return nil
    }
    
    func getPinView(flag: Flag) -> FlagAnnotationView? {
        let pin = getPin(flag)
        return pin == nil ? nil : map.viewForAnnotation(pin!) as? FlagAnnotationView
    }
    
    func createPin(flag: Flag) -> FlagAnnotation {
        return FlagAnnotation(flag: flag)
    }
}