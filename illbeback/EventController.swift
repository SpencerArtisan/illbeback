//
//  EventController.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

import MapKit

class EventController: UIViewController, UITextViewDelegate {
    var eventsModal: Modal!
    var memories: MemoriesController!
    
    init(memoriesViewController: MemoriesController) {
        super.init(nibName: nil, bundle: nil)
        eventsModal = Modal(viewName: "Events", owner: self)
        memories = memoriesViewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showEvents() {
        eventsModal.slideOutFromRight(self.memories.view)
    }
    
    func hideEvents() {
        eventsModal.slideInFromRight(self.memories.view)
    }
}