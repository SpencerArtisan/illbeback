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
    fileprivate let map: MKMapView
    fileprivate let mapController: MapController
    
    init(map: MKMapView, mapController: MapController) {
        self.map = map
        self.mapController = mapController
        super.init()
        Utils.addObserver(self, selector: #selector(FlagRenderer.onFlagAdded), event: "FlagAdded")
        Utils.addObserver(self, selector: #selector(FlagRenderer.onFlagRemoved), event: "FlagRemoved")
        Utils.addObserver(self, selector: #selector(FlagRenderer.onFlagSent), event: "FlagSent")
        Utils.addObserver(self, selector: #selector(FlagRenderer.onFlagReceiveSuccess), event: "FlagReceiveSuccess")
        Utils.addObserver(self, selector: #selector(FlagRenderer.onFlagChanged), event: "FlagChanged")
        Utils.addObserver(self, selector: #selector(FlagRenderer.onAckReceiveSuccess), event: "AckReceiveSuccess")
        Utils.addObserver(self, selector: #selector(FlagRenderer.onAcceptSuccess), event: "AcceptSuccess")
        Utils.addObserver(self, selector: #selector(FlagRenderer.onDeclineSuccess), event: "DeclineSuccess")
    }
    
    func render(_ mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is FlagAnnotation {
            let pinData = annotation as! FlagAnnotation
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
                
            
            if pinView != nil && pinView as? FlagAnnotationView != nil {
                pinView = FlagAnnotationView(mapController: mapController, flag: pinData.flag)
            }
            
            return pinView
        } else if annotation is ShapeCorner {
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "corner")
            
            if pinView != nil && pinView as? ShapeCornerView != nil {
                pinView = ShapeCornerView(mapController: mapController)
            }
            
            pinView?.isSelected = true

            return pinView
        }
        return nil
    }

    @objc func onAcceptSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        refreshImage(flag)
    }
    
    @objc func onDeclineSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isDead() {
            remove(flag)
        } else {
            refreshImage(flag)
        }
    }
    
    @objc func onFlagChanged(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        refresh(flag)
    }
    
    @objc func onFlagAdded(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        add(flag)
    }

    @objc func onFlagRemoved(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        remove(flag)
    }
    
    @objc func onFlagSent(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        refresh(flag)
    }
    
    @objc func onFlagReceiveSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        refresh(flag)
    }
    
    @objc func onAckReceiveSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        refresh(flag)
    }
    
    func add(_ flag: Flag) {
        Utils.runOnUiThread {
            let pin = self.createPin(flag)
            self.map.addAnnotation(pin)
        }
    }
    
    func remove(_ pin: FlagAnnotationView) {
        map.removeAnnotation(pin.annotation!)
    }
    
    func remove(_ flag: Flag) {
        let pin = getPin(flag)
        if pin != nil {
            print("Removed pin for \(flag.type())")
            map.removeAnnotation(pin!)
        }
    }
    
    func update(_ pin: FlagAnnotationView) {
        print("Replace pin")
        map.removeAnnotation(pin.annotation!)
        map.addAnnotation(createPin(pin.flag!))
    }
    
    func refresh(_ pin: FlagAnnotationView) {
        pin.refresh()
    }

    func refresh(_ flag: Flag) {
        Utils.runOnUiThread {
            if let pin = self.getPinView(flag) {
                self.refresh(pin)
            }
        }
    }
    
    func refreshImage(_ flag: Flag) {
        if let pin = getPinView(flag) {
            pin.refreshImage()
        }
    }
    
    func updateEventPins(_ events: [Flag]) {
        for event in events {
            refreshImage(event)
        }
    }
    
    func getPin(_ flag: Flag) -> FlagAnnotation? {
        for pin in self.map.annotations {
            if pin is FlagAnnotation && (pin as! FlagAnnotation).flag.id() == flag.id() {
                let flagAnnotation = pin as? FlagAnnotation
                return flagAnnotation
            }
        }
        return nil
    }
    
    func getPinView(_ flag: Flag) -> FlagAnnotationView? {
        let pin = getPin(flag)
        return pin == nil ? nil : map.view(for: pin!) as? FlagAnnotationView
    }
    
    func createPin(_ flag: Flag) -> FlagAnnotation {
        return FlagAnnotation(flag: flag)
    }
}
