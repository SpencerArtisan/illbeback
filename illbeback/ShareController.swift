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
        while (tag <= 10) {
            let shareButton = shareModal?.findElementByTag(tag++) as! UIButton
            shareButton.hidden = true
        }
        
        let newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        if (friends.count > 7) {
            newFriendButton.hidden = true
        } else {
            newFriendButton.hidden = false
            newFriendButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            newFriendButton.addTarget(self, action: "createNewFriend:", forControlEvents: .TouchUpInside)
            newFriendButton.enabled = true
            newFriendButton.setImage(nil, forState: UIControlState.Normal)
        }
        
        let newGroupButton = shareModal?.findElementByTag(1) as! UIButton
        if (friends.count > 7) {
            newGroupButton.hidden = true
        } else {
            newGroupButton.hidden = false
            newGroupButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            newGroupButton.addTarget(self, action: "createNewGroup:", forControlEvents: .TouchUpInside)
            newGroupButton.enabled = true
            newGroupButton.setImage(nil, forState: UIControlState.Normal)
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
        
        let newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        if (friends.count > 7) {
            newFriendButton.hidden = true
        } else {
            newFriendButton.hidden = false
            newFriendButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            newFriendButton.addTarget(self, action: "shareWithNewFriend:", forControlEvents: .TouchUpInside)
            newFriendButton.enabled = false
            newFriendButton.setImage(shareImage, forState: UIControlState.Normal)
            delay(0.5) { newFriendButton.enabled = true }
        }
        
        let newGroupButton = shareModal?.findElementByTag(1) as! UIButton
        if (friends.count > 7) {
            newGroupButton.hidden = true
        } else {
            newGroupButton.hidden = false
            newGroupButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            newGroupButton.addTarget(self, action: "shareWithNewGroup:", forControlEvents: .TouchUpInside)
            newGroupButton.enabled = true
            newGroupButton.setImage(shareImage, forState: UIControlState.Normal)
        }

        let cancelButton = shareModal?.findElementByTag(99) as! UIButton
        cancelButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
        cancelButton.addTarget(self, action: "shareMemoryCancelled:", forControlEvents: .TouchUpInside)
        cancelButton.enabled = false
        delay(0.5) { cancelButton.enabled = true }
    }
    
    func shareMemoryConfirmed(sender: AnyObject?) {
        let friend = (sender as! UIButton).titleLabel?.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        shareWith(friend!)
        hideShareModal(sender)
    }
    
    func shareWith(friend: String) {
        if pinsToShare.count == 0 {
            editFriends()
            return
        }
        
        for pin in pinsToShare {
            memories.memoryAlbum.share(pin, from: user.getName(), to: friend)
        }
        
        if pinsToShare.count == 1 {
            let memory = pinsToShare[0].memory
            let title = "Shared \(memory!.type) with \(friend)"
            let color = CategoryController.getColorForCategory(memory!.type)
            memories.showMessage(title, color: color, time: 1.6)
        } else {
            let title = "Shared \(pinsToShare.count) flags with \(friend)"
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
        newFriend(sender, cancelAction: "shareNewFriendCancelled:")
    }
    
    func createNewFriend(sender: AnyObject?) {
        newFriend(sender, cancelAction: "createNewFriendCancelled:")
    }
    
    func newFriend(sender: AnyObject?, cancelAction: Selector) {
        hideShareModal(sender)
        memories.newUserLabel.text = "Your friend's name"
        memories.newUserText.becomeFirstResponder()
        memories.newUserText.text = ""
        memories.newUserModal?.slideOutFromRight(memories.view)
        let cancelButton = memories.newUserModal?.findElementByTag(4) as! UIButton
        cancelButton.addTarget(self, action: cancelAction, forControlEvents: .TouchUpInside)
        cancelButton.enabled = false
        delay(0.5) { cancelButton.enabled = true }
    }
    
    func shareWithNewGroup(sender: AnyObject?) {
        newGroup(sender, cancelAction: "shareNewGroupCancelled:")
    }
    
    func createNewGroup(sender: AnyObject?) {
        newGroup(sender, cancelAction: "createNewGroupCancelled:")
    }
    
    func newGroup(sender: AnyObject?, cancelAction: Selector) {
        let newGroupButton = shareModal?.findElementByTag(1) as! UIButton
        newGroupButton.hidden = true
        
        let newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        newFriendButton.hidden = true
        
        
        let addImage = UIImage(named: "add")!
        var tag = 3
        let friends: [String] = user.getFriends()
        for friend in friends {
            let shareButton = shareModal?.findElementByTag(tag++) as! UIButton
            shareButton.setTitle(friend, forState: UIControlState.Normal)
            shareButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
            shareButton.addTarget(self, action: "addFriendToGroupConfirmed:", forControlEvents: .TouchUpInside)
            shareButton.setImage(addImage, forState: UIControlState.Normal)
            shareButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        }
        
//        memories.createGroupMode()

//        hideShareModal(sender)
//        memories.newUserLabel.text = "Name your group"
//        memories.newUserText.becomeFirstResponder()
//        memories.newUserText.text = ""
//        memories.newUserModal?.slideOutFromRight(memories.view)
//        let cancelButton = memories.newUserModal?.findElementByTag(4) as! UIButton
//        cancelButton.addTarget(self, action: cancelAction, forControlEvents: .TouchUpInside)
//        cancelButton.enabled = false
//        delay(0.5) { cancelButton.enabled = true }
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

    func addFriendToGroupConfirmed(sender: AnyObject?) {
        let tickImage = UIImage(named: "share flag")!
        let button = (sender as! UIButton)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.setImage(tickImage, forState: UIControlState.Normal)
//        let friend = (sender as! UIButton).titleLabel?.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//        user.removeFriend(friend!)
//        showEditFriends()
    }
}