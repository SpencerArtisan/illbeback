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
    
    func editFriends() {
        shareModal?.slideOutFromLeft(memories.view)
        showEditFriends()
    }
 
    func showEditFriends() {
        let deleteImage = UIImage(named: "trash")!
        
        var tag = 3
        let friends: [String] = user.getFriends()
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

        shareModal?.slideOutFromLeft(memories.view)
        let shareImage = UIImage(named: "share")!
       
        var tag = 3
        let friends: [String] = user.getFriends()
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
     
        let title = pinsToShare.count == 1 ? "Sending \(pinsToShare[0].memory!.type) to \(friend)" : "Sending \(pinsToShare.count) flags to \(friend)"
        let color = CategoryController.getColorForCategory(pinsToShare.count == 1 ? pinsToShare[0].memory!.type : "Memory")
        var message = memories.showMessage(title, color: color, time: nil)

        let total = pinsToShare.count
        var remaining = total
        var failed = 0
        
        for pin in pinsToShare {
            memories.memoryAlbum.share(pin, from: user.getName(), to: friend, onComplete: {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.memories.delay(0.4) {
                        self.memories.dismissMessage(message)
                        if remaining == 1 && total == 1 {
                            self.memories.showMessage("Sent", color: UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0), time: 1.6)
                        } else if remaining == 1 {
                            self.memories.showMessage("Sent all", color: UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0), time: 1.6)
                        } else {
                            remaining--
                            message = self.memories.showMessage("Sent \(total - remaining) of \(total)", color: color, time: nil)
                        }
                        self.memories.memoryAlbum.save()
                        self.memories.map.deselectAnnotation(pin.annotation, animated: false)
                        pin.refresh()
                    }
                }
            }, onError: {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.memories.delay(0.4) {
                        self.memories.dismissMessage(message)
                        if remaining == 1  && total == 1 {
                            self.memories.showMessage("Failed", color: UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0), time: 2.0)
                        } else if remaining == 1 {
                            failed++
                            message = self.memories.showMessage("Failed sending \(failed) out of \(total) flags", color: UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0), time: 2.6)
                        } else {
                            remaining--
                            failed++
                            message = self.memories.showMessage("Failed sending \(failed) out of \(total) flags", color: UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0), time: nil)
                        }
                    }
                }
            })
        }
        
        pinsToShare = []
        memories.shapeModal?.slideUpFromTop(view)
        memories.shapeController.clear()
        memories.showPinsInShape()
    }
    
    func acceptRecentShare(memory: Memory) {
        memories.memoryAlbum.acceptRecentShare(memory, from: user.getName())
    }
    
    func declineRecentShare(memory: Memory) {
        memories.memoryAlbum.declineRecentShare(memory, from: user.getName())
    }
    
    func hideShareModal(sender: AnyObject?) {
        shareModal?.slideInFromLeft(memories.view)
    }
    
    func shareWithNewFriend(sender: AnyObject?) {
        newFriend(sender, cancelAction: "shareNewFriendCancelled:")
    }
    
    func createNewFriend(sender: AnyObject?) {
        newFriend(sender, cancelAction: "createNewFriendCancelled:")
    }
    
    func newFriend(sender: AnyObject?, cancelAction: Selector) {
        hideShareModal(sender)
        memories.newUserLabel.text = "Friend's sharing name"
        memories.newUserText.becomeFirstResponder()
        memories.newUserText.text = ""
        memories.newUserModal?.slideOutFromRight(memories.view)
        let cancelButton = memories.newUserModal?.findElementByTag(4) as! UIButton
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
        shareModal?.slideInFromLeft(memories.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
    }
    
    func shareNewFriendCancelled(sender: AnyObject?) {
        memories.newUserText.resignFirstResponder()
        pinsToShare = []
        memories.newUserModal?.slideInFromRight(memories.view)
        ((sender) as! UIButton).removeTarget(self, action: "shareNewFriendCancelled:", forControlEvents: .TouchUpInside)
    }
    
    func deleteFriendConfirmed(sender: AnyObject?) {
        let friend = (sender as! UIButton).titleLabel?.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        user.removeFriend(friend!)
        showEditFriends()
    }
    
    func createNewFriendCancelled(sender: AnyObject?) {
        memories.newUserText.resignFirstResponder()
        pinsToShare = []
        memories.newUserModal?.slideInFromRight(memories.view)
        showEditFriends()
    }
}