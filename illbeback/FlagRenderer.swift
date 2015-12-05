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
    private let memoriesController: MemoriesController
    
    init(map: MKMapView, memoriesController: MemoriesController) {
        self.map = map
        self.memoriesController = memoriesController
        super.init()
        Utils.addObserver(self, selector: "onFlagAdded:", event: "FlagAdded")
        Utils.addObserver(self, selector: "onFlagRemoved:", event: "FlagRemoved")
    }
    
    func render(viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MapPin {
            let pinData = annotation as! MapPin
            var pinView = map.dequeueReusableAnnotationViewWithIdentifier("pin") as! MapPinView!
            
            if pinView == nil {
                pinView = MapPinView(memoriesController: memoriesController, flag: pinData.flag)
            }
            
            return pinView
        } else if annotation is ShapeCorner {
            var pinView = map.dequeueReusableAnnotationViewWithIdentifier("corner") as! ShapeCornerView!
            
            if pinView == nil {
                pinView = ShapeCornerView(memoriesController: memoriesController)
            }
            
            pinView.setSelected(true, animated: true)
            
            return pinView
        }
        return nil
    }

    func onFlagAdded(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        print("\(flag.type()) added to repo.  Adding it to map...")
        add(flag)
    }

    func onFlagRemoved(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        print("\(flag.type()) removed from repo.  Removing from map...")
        remove(flag)
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
        print("Removed pin for \(flag.encode())")
        map.removeAnnotation(getPin(flag)!)
    }
    
    func update(pin: MapPinView) {
        map.removeAnnotation(pin.annotation!)
        map.addAnnotation(createPin(pin.flag!))
    }
    
    func refresh(pin: MapPinView) {
        map.deselectAnnotation(pin.annotation, animated: false)
        pin.refresh()
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
                    map.removeAnnotation(pin!)
                    map.addAnnotation(pin!)
                }
            }
        }
    }
    
    func getPin(flag: Flag) -> MapPin? {
        for pin in self.map.annotations {
            if pin is MapPin && (pin as! MapPin).flag.id() == flag.id() {
                return pin as? MapPin
            }
        }
        return nil
    }
    
    func createPin(flag: Flag) -> MapPin {
        return MapPin(flag: flag)
    }
}