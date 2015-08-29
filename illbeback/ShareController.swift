//
//  ShareController.swift
//  illbeback
//
//  Created by Spencer Ward on 29/08/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

class ShareController : UIViewController {
    var user: User
    var shareModal: Modal?
    var pinsToShare: [MapPinView] = []
    var memories: MemoriesController
    
    init(user: User, memories: MemoriesController) {
        self.shareModal = Modal(viewName: "ShareView", owner: memories)
        self.memories = memories
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Callback for button on the callout
    func shareMemory(pins: [MapPinView]) {
        shareModal?.slideOutFromLeft(memories.view)
        pinsToShare = pins
        
        var tag = 3
        let friends: [String] = user.getFriends()
        for friend in friends {
            var shareButton = shareModal?.findElementByTag(tag++) as! UIButton
            shareButton.setTitle(" " + friend, forState: UIControlState.Normal)
            shareButton.hidden = false
            shareButton.addTarget(self, action: "shareMemoryConfirmed:", forControlEvents: .TouchUpInside)
            shareButton.enabled = false
            delay(0.5) { shareButton.enabled = true }
        }
        
        var newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        if (friends.count > 7) {
            newFriendButton.hidden = true
        } else {
            newFriendButton.addTarget(self, action: "shareWithNewFriend:", forControlEvents: .TouchUpInside)
            newFriendButton.enabled = false
            delay(0.5) { newFriendButton.enabled = true }
        }
        var cancelButton = shareModal?.findElementByTag(1) as! UIButton
        cancelButton.addTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
        cancelButton.enabled = false
        delay(0.5) { cancelButton.enabled = true }
    }
    
    func shareMemoryConfirmed(sender: AnyObject?) {
        var friend = (sender as! UIButton).titleLabel?.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        shareWith(friend!)
        hideShareModal(sender)
    }
    
    func shareWith(friend: String) {
        for pin in pinsToShare {
            memories.memoryAlbum.share(pin, from: user.getName(), to: friend)
        }
        
        if pinsToShare.count == 1 {
            var memory = pinsToShare[0].memory
            var title = "Shared \(memory!.type) with \(friend)"
            var color = CategoryController.getColorForCategory(memory!.type)
            memories.showMessage(title, color: color, time: 1.6)
        } else {
            var title = "Shared \(pinsToShare.count) flags with \(friend)"
            memories.showMessage(title, color: CategoryController.getColorForCategory("Memory"), time: 1.6)
        }
        
        pinsToShare = []
        memories.shapeModal?.slideUpFromTop(view)
        memories.shapeController.clear()
        memories.showPinsInShape()
    }
    
    func hideShareModal(sender: AnyObject?) {
        shareModal?.slideInFromLeft(memories.view)
    }
    
    func shareWithNewFriend(sender: AnyObject?) {
        hideShareModal(sender)
        memories.newUserLabel.text = "Your friend's name"
        memories.newUserText.becomeFirstResponder()
        memories.newUserText.text = ""
        memories.newUserModal?.slideOutFromRight(memories.view)
        var cancelButton2 = memories.newUserModal?.findElementByTag(4) as! UIButton
        cancelButton2.addTarget(self, action: "shareNewFriendCancelled:", forControlEvents: .TouchUpInside)
        cancelButton2.enabled = false
        delay(0.5) { cancelButton2.enabled = true }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func shareMemoryCancelled(sender: AnyObject?) {
        pinsToShare = []
        shareModal?.slideInFromLeft(memories.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
    }
    
    func shareNewFriendCancelled(sender: AnyObject?) {
        memories.newUserText.resignFirstResponder()
        pinsToShare = []
        memories.newUserModal?.slideInFromRight(memories.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareNewFriendCancelled:", forControlEvents: .TouchUpInside)
    }

}