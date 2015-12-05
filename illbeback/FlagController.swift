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
    var memoriesController: MemoriesController!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    init(memoriesViewController: MemoriesController) {
        super.init(nibName: nil, bundle: nil)
        flagsModal = Modal(viewName: "FlagsView", owner: self)
        memoriesController = memoriesViewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func cancel(sender: AnyObject) {
        cancelButton.enabled = false
        hideFlags()
    }
    
    func showFlags() {
        Utils.delay(1) {
            self.cancelButton.enabled = true
        }
        let flags = memoriesController.flagRepository.new()
        var tag = 1
        for flag in flags {
            let flagView = flagsModal.findElementByTag(tag) as? FlagView
            if flagView == nil {
                break;
            }
            flagView!.setFlag(flag)
            flagView!.memoriesController = memoriesController
            flagView!.hidden = false
            tag++
        }
        while (true) {
            let flagView = flagsModal.findElementByTag(tag) as? FlagView
            if flagView == nil {
                break;
            }
            flagView!.hidden = true
            tag++
        }
        
        flagsModal.slideOutFromLeft(self.memoriesController.view)
    }
    
    func hideFlags() {
        flagsModal.slideInFromLeft(self.memoriesController.view)
    }
}