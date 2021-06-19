//
//  HintController.swift
//  illbeback
//
//  Created by Spencer Ward on 17/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class HintController : NSObject {
    fileprivate var mapController: MapController!
    fileprivate var hintModal: Modal!

    init(mapController: MapController) {
        super.init()
        self.mapController = mapController
        self.hintModal = Modal(viewName: "Hint", owner: mapController, preserveHeight: true)
        let cancelHint = hintModal!.findElementByTag(2) as! UIButton
        cancelHint.addTarget(self, action: #selector(onClickHint), for: UIControl.Event.touchUpInside)
    }
    
    func backupRestoringHint() {
        image(4).isHidden = true
        image(5).isHidden = true
        hint("Please wait.\r\nYour backup is being restored.", fromBottom: mapController.view.frame.height - 330)
    }
    
    func backupRestoredHint() {
        image(4).isHidden = true
        image(5).isHidden = true
        hint("Your backup has been restored!", fromBottom: mapController.view.frame.height - 330)
    }
    
    func firstFlagHint() {
        image(4).isHidden = true
        image(5).isHidden = true
        hint("Click on the flag to share with friends or take more photos", fromBottom: mapController.view.frame.height - 300)
    }
    
    func photoHint() {
        image(4).isHidden = false
        image(5).isHidden = true
        hint("Take a photo and it will pin it to the map", fromBottom: 74)
    }
    
    func pressMapHint() {
        image(4).isHidden = true
        image(5).isHidden = true
        hint("You can also add flags by pressing on the map for a couple of seconds", fromBottom: mapController.view.frame.height - 300)
    }
    
    func backupHint() {
        image(4).isHidden = true
        image(5).isHidden = false
        hint("Now you have a few flags, you might want to back them up from time to time", fromBottom: mapController.view.frame.height - 335)
    }
    
    fileprivate func image(_ tag: Int) -> UIImageView {
        return (hintModal!.findElementByTag(tag) as! UIImageView)
    }
    
    fileprivate func hint(_ text: String, fromBottom: CGFloat) {
        hintModal.fromBottom(fromBottom)
        let message = hintModal!.findElementByTag(1) as! UILabel
        message.text = text
        hintModal!.slideOutFromLeft(mapController.view)
    }
    
    @objc func onClickHint(_ sender : UIButton!) {
        dismissHint()
    }

    func dismissHint() {
        hintModal?.slideInFromLeft(mapController.view)
    }
}
