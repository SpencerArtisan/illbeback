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
    var pinsToShare: [FlagAnnotationView] = []
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
            let shareButton = shareModal?.findElementByTag(tag) as! UIButton
            tag = tag + 1
            shareButton.setTitle(" " + friend, for: UIControl.State())
            shareButton.isHidden = false
            shareButton.removeTarget(self, action: nil, for: .touchUpInside)
            shareButton.addTarget(self, action: #selector(ShareController.deleteFriendConfirmed(_:)), for: .touchUpInside)
            shareButton.setTitleColor(UIColor.black, for: UIControl.State())
            shareButton.isEnabled = true
            shareButton.setImage(deleteImage, for: UIControl.State())
        }
        while (tag <= 15) {
            let shareButton = shareModal?.findElementByTag(tag) as! UIButton
            tag = tag + 1
            shareButton.isHidden = true
        }
        
        let newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        if (friends.count > 12) {
            newFriendButton.isHidden = true
        } else {
            newFriendButton.isHidden = false
            newFriendButton.removeTarget(self, action: nil, for: .touchUpInside)
            newFriendButton.addTarget(self, action: #selector(ShareController.createNewFriend(_:)), for: .touchUpInside)
            newFriendButton.isEnabled = true
            newFriendButton.setImage(nil, for: UIControl.State())
        }
        
        let cancelButton = shareModal?.findElementByTag(99) as! UIButton
        cancelButton.removeTarget(self, action: nil, for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(ShareController.shareMemoryCancelled(_:)), for: .touchUpInside)
        cancelButton.isEnabled = false
        delay(0.5) { cancelButton.isEnabled = true }
    }
    
    // Callback for button on the callout
    func shareFlag(_ pins: [FlagAnnotationView]) {
        pinsToShare = pins

        shareModal?.slideOutFromLeft(mapController.view)
        let shareImage = UIImage(named: "share")!
       
        var tag = 3
        let friends: [String] = Global.getUser().getFriends()
        for friend in friends {
            let shareButton = shareModal?.findElementByTag(tag) as! UIButton
            tag = tag + 1
            shareButton.setTitle(" " + friend, for: UIControl.State())
            shareButton.isHidden = false
            shareButton.removeTarget(self, action: nil, for: .touchUpInside)
            shareButton.addTarget(self, action: #selector(ShareController.shareMemoryConfirmed(_:)), for: .touchUpInside)
            shareButton.setTitleColor(UIColor.black, for: UIControl.State())
            shareButton.isEnabled = false
            shareButton.setImage(shareImage, for: UIControl.State())
            delay(0.5) { shareButton.isEnabled = true }
        }
        while (tag <= 15) {
            let shareButton = shareModal?.findElementByTag(tag) as! UIButton
            tag = tag + 1
            shareButton.isHidden = true
        }
        
        let newFriendButton = shareModal?.findElementByTag(2) as! UIButton
        if (friends.count > 12) {
            newFriendButton.isHidden = true
        } else {
            newFriendButton.isHidden = false
            newFriendButton.removeTarget(self, action: nil, for: .touchUpInside)
            newFriendButton.addTarget(self, action: #selector(ShareController.shareWithNewFriend(_:)), for: .touchUpInside)
            newFriendButton.isEnabled = false
            newFriendButton.setImage(shareImage, for: UIControl.State())
            delay(0.5) { newFriendButton.isEnabled = true }
        }
        
        let cancelButton = shareModal?.findElementByTag(99) as! UIButton
        cancelButton.removeTarget(self, action: nil, for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(ShareController.shareMemoryCancelled(_:)), for: .touchUpInside)
        cancelButton.isEnabled = false
        delay(0.5) { cancelButton.isEnabled = true }
    }
    
    func shareWith(_ friend: String) {
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
    
    func hideShareModal(_ sender: AnyObject?) {
        shareModal?.slideInFromLeft(mapController.view)
    }
    
    @objc func shareWithNewFriend(_ sender: AnyObject?) {
        newFriend(sender, cancelAction: #selector(ShareController.shareNewFriendCancelled(_:)))
    }
    
    @objc func createNewFriend(_ sender: AnyObject?) {
        newFriend(sender, cancelAction: #selector(ShareController.createNewFriendCancelled(_:)))
    }
    
    func newFriend(_ sender: AnyObject?, cancelAction: Selector) {
        hideShareModal(sender)
        mapController.newUserLabel.text = "Friend's username"
        mapController.newUserText.becomeFirstResponder()
        mapController.newUserText.text = ""
        mapController.newUserModal?.slideOutFromRight(mapController.view)
        let cancelButton = mapController.newUserModal?.findElementByTag(4) as! UIButton
        cancelButton.addTarget(self, action: cancelAction, for: .touchUpInside)
        cancelButton.isEnabled = false
        delay(0.5) { cancelButton.isEnabled = true }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    @objc func shareMemoryConfirmed(_ sender: AnyObject?) {
        let friend = (sender as! UIButton).titleLabel?.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        shareWith(friend!)
        hideShareModal(sender)
    }
    
    @objc func shareMemoryCancelled(_ sender: AnyObject?) {
        pinsToShare = []
        shareModal?.slideInFromLeft(mapController.view)
        ((sender) as! UIButton).removeTarget(self, action: #selector(ShareController.shareMemoryCancelled(_:)), for: .touchUpInside)
    }
    
    @objc func shareNewFriendCancelled(_ sender: AnyObject?) {
        mapController.newUserText.resignFirstResponder()
        pinsToShare = []
        mapController.newUserModal?.slideInFromRight(mapController.view)
        ((sender) as! UIButton).removeTarget(self, action: #selector(ShareController.shareNewFriendCancelled(_:)), for: .touchUpInside)
    }
    
    @objc func deleteFriendConfirmed(_ sender: AnyObject?) {
        let friend = (sender as! UIButton).titleLabel?.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        Global.getUser().removeFriend(friend!)
        Preferences.user(Global.getUser())
        showEditFriends()
    }
    
    @objc func createNewFriendCancelled(_ sender: AnyObject?) {
        mapController.newUserText.resignFirstResponder()
        pinsToShare = []
        mapController.newUserModal?.slideInFromRight(mapController.view)
        showEditFriends()
    }
}
