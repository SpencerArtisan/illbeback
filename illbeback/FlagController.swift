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
    var memories: MemoriesController!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    init(memoriesViewController: MemoriesController) {
        super.init(nibName: nil, bundle: nil)
        flagsModal = Modal(viewName: "FlagsView", owner: self)
        memories = memoriesViewController
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
        delay(1) {
            self.cancelButton.enabled = true
        }
        let flags = memories.memoryAlbum.getNewMemories()
        var tag = 1
        for flag in flags {
            let flagView = flagsModal.findElementByTag(tag) as? FlagView
            if flagView == nil {
                break;
            }
            flagView!.setMemory(flag)
            flagView!.memories = memories
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
        
        flagsModal.slideOutFromLeft(self.memories.view)
    }
    
    func hideFlags() {
        flagsModal.slideInFromLeft(self.memories.view)
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