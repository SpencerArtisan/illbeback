//
//  HintController.swift
//  illbeback
//
//  Created by Spencer Ward on 17/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class HintController : NSObject {
    private var mapController: MapController!
    private var hintModal: Modal!

    init(mapController: MapController) {
        super.init()
        self.mapController = mapController
        self.hintModal = Modal(viewName: "Hint", owner: mapController, preserveHeight: true)
        let cancelHint = hintModal!.findElementByTag(2) as! UIButton
        cancelHint.addTarget(self, action: "onClickHint:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func photoHint() {
        image(4).hidden = false
        image(5).hidden = true
        hint("Take a photo and it will pin it to the map", fromBottom: 74)
    }
    
    func pressMapHint() {
        image(4).hidden = true
        image(5).hidden = true
        hint("You can also add flags by pressing on the map for a couple of seconds", fromBottom: mapController.view.frame.height - 300)
    }
    
    func backupHint() {
        image(4).hidden = true
        image(5).hidden = false
        hint("Now you have a few flags, you might want to back them up from time to time", fromBottom: mapController.view.frame.height - 300)
    }
    
    private func image(tag: Int) -> UIImageView {
        return (hintModal!.findElementByTag(tag) as! UIImageView)
    }
    
    private func hint(text: String, fromBottom: CGFloat) {
        hintModal.fromBottom(fromBottom)
        let message = hintModal!.findElementByTag(1) as! UILabel
        message.text = text
        hintModal!.slideOutFromLeft(mapController.view)
    }
    
    func onClickHint(sender : UIButton!) {
        dismissHint()
    }

    func dismissHint() {
        hintModal?.slideInFromLeft(mapController.view)
    }
}