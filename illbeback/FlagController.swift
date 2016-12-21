//
//  FlagController.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

import MapKit

class FlagsController: UIViewController, UITextViewDelegate {
    var flagsModal: Modal!
    var mapController: MapController!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    init(mapController: MapController) {
        super.init(nibName: nil, bundle: nil)
        flagsModal = Modal(viewName: "FlagsView", owner: self)
        self.mapController = mapController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        cancelButton.isEnabled = false
        hideFlags()
    }
    
    func showFlags() {
        Utils.delay(1) {
            self.cancelButton.isEnabled = true
        }
        let flags = mapController.flagRepository.new()
        var tag = 1
        for flag in flags {
            let flagView = flagsModal.findElementByTag(tag) as? FlagView
            if flagView == nil {
                break;
            }
            flagView!.setFlag(flag)
            flagView!.mapController = mapController
            flagView!.isHidden = false
            tag += 1
        }
        while (true) {
            let flagView = flagsModal.findElementByTag(tag) as? FlagView
            if flagView == nil {
                break;
            }
            flagView!.isHidden = true
            tag += 1
        }
        
        flagsModal.slideOutFromLeft(self.mapController.view)
    }
    
    func hideFlags() {
        flagsModal.slideInFromLeft(self.mapController.view)
    }
}
