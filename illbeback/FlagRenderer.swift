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
    }
    
    func render(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MapPin {
            let pinData = annotation as! MapPin
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as! MapPinView!
            
            if pinView == nil {
                pinView = MapPinView(mapController: mapController, flag: pinData.flag)
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
        Utils.runOnUiThread() {
            let pin = self.createPin(flag)
            self.map.addAnnotation(pin)
        }
    }
    
    func remove(pin: MapPinView) {
        map.removeAnnotation(pin.annotation!)
    }
    
    func remove(flag: Flag) {
        let pin = getPin(flag)
        if pin != nil {
            print("Removed pin for \(flag.type())")
            map.removeAnnotation(pin!)
        }
    }
    
    func update(pin: MapPinView) {
        print("Replace pin")
        map.removeAnnotation(pin.annotation!)
        map.addAnnotation(createPin(pin.flag!))
    }
    
    func refresh(pin: MapPinView) {
        pin.refresh()
    }

    func refresh(flag: Flag) {
        if let pin = getPinView(flag) {
            refresh(pin)
        }
    }
    
    func updateEventPins(events: [Flag]) {
        for event in events {
            let pin = getPin(event)
            if pin != nil {
                if event.isPast() {
                    print("Removing old event \(event.id)")
                    self.map.deselectAnnotation(pin, animated: false)
                    Utils.runOnUiThread2() {
                        self.map.removeAnnotation(pin!)
                    }
                } else {
                    print("Update event pin")
                    map.removeAnnotation(pin!)
                    map.addAnnotation(pin!)
                }
            }
        }
    }
    
    func getPin(flag: Flag) -> MapPin? {
        for pin in self.map.annotations {
            if pin is MapPin && (pin as! MapPin).flag.id() == flag.id() {
                let mapPin = pin as? MapPin
                return mapPin
            }
        }
        return nil
    }
    
    func getPinView(flag: Flag) -> MapPinView? {
        let pin = getPin(flag)
        return pin == nil ? nil : map.viewForAnnotation(pin!) as? MapPinView
    }
    
    func createPin(flag: Flag) -> MapPin {
        return MapPin(flag: flag)
    }
}