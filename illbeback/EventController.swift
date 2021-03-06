//
//  EventController.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

import MapKit

class EventsController: UIViewController, UITextViewDelegate {
    var eventsModal: Modal!
    var mapController: MapController!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    init(mapController: MapController) {
        super.init(nibName: nil, bundle: nil)
        eventsModal = Modal(viewName: "Events", owner: self)
        self.mapController = mapController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showEvents() {
        delay(1) {
            self.cancelButton.enabled = true
        }
        let events = mapController.flagRepository.events()
        var tag = 1
        for event in events {
            let eventView = eventsModal.findElementByTag(tag) as? EventView
            if eventView == nil {
                break;
            }
            eventView!.setEvent(event)
            eventView!.mapController = mapController
            eventView!.hidden = false
            tag++
        }
        while (true) {
            let eventView = eventsModal.findElementByTag(tag) as? EventView
            if eventView == nil {
                break;
            }
            eventView!.hidden = true
            tag++
        }
        
        eventsModal.slideOutFromRight(self.mapController.view)
    }
    
    func hideEvents() {
        eventsModal.slideInFromRight(self.mapController.view)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        cancelButton.enabled = false
        hideEvents()
    }
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}