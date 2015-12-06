//
//  ShareController.swift
//  illbeback
//
//  Created by Spencer Ward on 29/08/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

class ShareController : UIViewController {
    var shareModal: Modal?
    var pinsToShare: [MapPinView] = []
    var mapController: MapController
    var outBox: OutBox
    
    init(mapController: MapController) {
        self.shareModal = Modal(viewName: "ShareView", owner: mapController)
        self.mapController = mapController
        self.outBox = OutBox(flagRepository: mapController.flagRepository, photoAlbum: mapController.photoAlbum)
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func editFriends() {
        shareModal?.slideOutFromLeft(mapController.view)
        showEditFriends()
    }
 
    func showEditFriends() {
        let deleteImage = UIImage(named: "trash")!
        
        var tag = 3
        let friends: [String] = Global.getUser().getFriends()
        for friend in friends {
            let shareButton = shareModal?.findElementByTag(tag++) as! UIButton
            shareButton.setTitle(" " + friend, forState: UIControlState.Normal)
            shareButton.hidden = false
            shareButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            shareButton.addTarget(self, action: "deleteFriendConfirmed:", forControlEvents: .TouchUpInside)
            shareButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            shareButton.enabled = true
            shareButton.setImage(deleteImage, forState: UIControlState.Normal)
        }
        while (tag <= 15) {
            let shareButton = shareModal?.findElementByTag(tag++) as! UIButton
            shareButton.hidden = true
        }
        
        let newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        if (friends.count > 12) {
            newFriendButton.hidden = true
        } else {
            newFriendButton.hidden = false
            newFriendButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            newFriendButton.addTarget(self, action: "createNewFriend:", forControlEvents: .TouchUpInside)
            newFriendButton.enabled = true
            newFriendButton.setImage(nil, forState: UIControlState.Normal)
        }
        
        let cancelButton = shareModal?.findElementByTag(99) as! UIButton
        cancelButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
        cancelButton.addTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
        cancelButton.enabled = false
        delay(0.5) { cancelButton.enabled = true }
    }
    
    // Callback for button on the callout
    func shareMemory(pins: [MapPinView]) {
        pinsToShare = pins

        shareModal?.slideOutFromLeft(mapController.view)
        let shareImage = UIImage(named: "share")!
       
        var tag = 3
        let friends: [String] = Global.getUser().getFriends()
        for friend in friends {
            let shareButton = shareModal?.findElementByTag(tag++) as! UIButton
            shareButton.setTitle(" " + friend, forState: UIControlState.Normal)
            shareButton.hidden = false
            shareButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            shareButton.addTarget(self, action: "shareMemoryConfirmed:", forControlEvents: .TouchUpInside)
            shareButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            shareButton.enabled = false
            shareButton.setImage(shareImage, forState: UIControlState.Normal)
            delay(0.5) { shareButton.enabled = true }
        }
        while (tag <= 15) {
            let shareButton = shareModal?.findElementByTag(tag++) as! UIButton
            shareButton.hidden = true
        }
        
        let newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        if (friends.count > 12) {
            newFriendButton.hidden = true
        } else {
            newFriendButton.hidden = false
            newFriendButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            newFriendButton.addTarget(self, action: "shareWithNewFriend:", forControlEvents: .TouchUpInside)
            newFriendButton.enabled = false
            newFriendButton.setImage(shareImage, forState: UIControlState.Normal)
            delay(0.5) { newFriendButton.enabled = true }
        }
        
        let cancelButton = shareModal?.findElementByTag(99) as! UIButton
        cancelButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
        cancelButton.addTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
        cancelButton.enabled = false
        delay(0.5) { cancelButton.enabled = true }
    }
    
    func shareWith(friend: String) {
        if pinsToShare.count == 0 {
            editFriends()
            return
        }
        
        for pin in pinsToShare {
            let flag = pin.flag!
            flag.invite(friend)
        }
        
        outBox.send()
    }
    
    func hideShareModal(sender: AnyObject?) {
        shareModal?.slideInFromLeft(mapController.view)
    }
    
    func shareWithNewFriend(sender: AnyObject?) {
        newFriend(sender, cancelAction: "shareNewFriendCancelled:")
    }
    
    func createNewFriend(sender: AnyObject?) {
        newFriend(sender, cancelAction: "createNewFriendCancelled:")
    }
    
    func newFriend(sender: AnyObject?, cancelAction: Selector) {
        hideShareModal(sender)
        mapController.newUserLabel.text = "Friend's sharing name"
        mapController.newUserText.becomeFirstResponder()
        mapController.newUserText.text = ""
        mapController.newUserModal?.slideOutFromRight(mapController.view)
        let cancelButton = mapController.newUserModal?.findElementByTag(4) as! UIButton
        cancelButton.addTarget(self, action: cancelAction, forControlEvents: .TouchUpInside)
        cancelButton.enabled = false
        delay(0.5) { cancelButton.enabled = true }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func shareMemoryConfirmed(sender: AnyObject?) {
        let friend = (sender as! UIButton).titleLabel?.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        shareWith(friend!)
        hideShareModal(sender)
    }
    
    func shareMemoryCancelled(sender: AnyObject?) {
        pinsToShare = []
        shareModal?.slideInFromLeft(mapController.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
    }
    
    func shareNewFriendCancelled(sender: AnyObject?) {
        mapController.newUserText.resignFirstResponder()
        pinsToShare = []
        mapController.newUserModal?.slideInFromRight(mapController.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareNewFriendCancelled:", forControlEvents: .TouchUpInside)
    }
    
    func deleteFriendConfirmed(sender: AnyObject?) {
        let friend = (sender as! UIButton).titleLabel?.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        Global.getUser().removeFriend(friend!)
        showEditFriends()
    }
    
    func createNewFriendCancelled(sender: AnyObject?) {
        mapController.newUserText.resignFirstResponder()
        pinsToShare = []
        mapController.newUserModal?.slideInFromRight(mapController.view)
        showEditFriends()
    }
}