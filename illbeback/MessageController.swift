//
//  MessageController.swift
//  illbeback
//
//  Created by Spencer Ward on 07/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class MessageController : NSObject {
    private var mapController: MapController!
    private var activeModals = [String: Modal] ()
    private var messageModals: [Modal] = []
    
    init(mapController: MapController) {
        super.init()
        self.mapController = mapController
        Utils.addObserver(self, selector: "onNameTaken:", event: "NameTaken")
        Utils.addObserver(self, selector: "onNameAccepted:", event: "NameAccepted")
        Utils.addObserver(self, selector: "onEventListChange:", event: "EventListChange")
        Utils.addObserver(self, selector: "onFlagSending:", event: "FlagSending")
        Utils.addObserver(self, selector: "onFlagSendSuccess:", event: "FlagSendSuccess")
        Utils.addObserver(self, selector: "onFlagSendFailed:", event: "FlagSendFailed")
        Utils.addObserver(self, selector: "onFlagReceiving:", event: "FlagReceiving")
        Utils.addObserver(self, selector: "onFlagReceiveSuccess:", event: "FlagReceiveSuccess")
        Utils.addObserver(self, selector: "onFlagReceiveFailed:", event: "FlagReceiveFailed")
        Utils.addObserver(self, selector: "onAckReceiveSuccess:", event: "AckReceiveSuccess")
        Utils.addObserver(self, selector: "onDeclining:", event: "Declining")
        Utils.addObserver(self, selector: "onDeclineSuccess:", event: "DeclineSuccess")
        Utils.addObserver(self, selector: "onDeclineFailed:", event: "DeclineFailed")
        Utils.addObserver(self, selector: "onAccepting:", event: "Accepting")
        Utils.addObserver(self, selector: "onAcceptSuccess:", event: "AcceptSuccess")
        Utils.addObserver(self, selector: "onAcceptFailed:", event: "AcceptFailed")
        Utils.addObserver(self, selector: "onBackupPreparing:", event: "BackupPreparing")
        Utils.addObserver(self, selector: "onBackupPrepared:", event: "BackupPrepared")
    }
    
    func onFlagSending(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        let to = note.userInfo!["to"] as! String
        let message = "Sending \(flag.type()) to \(to)"
        preMessage(message, key: flag.id()+to, flag: flag)
    }
    
    func onFlagSendSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        let to = note.userInfo!["to"] as! String
        let message = "Sent \(flag.type()) to \(to)"
        postMessage(message, key:  flag.id()+to, flag: flag, success: true)
    }
    
    func onFlagSendFailed(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        let to = note.userInfo!["to"] as! String
        let message = "Failed sending \(flag.type()) to \(to)"
        postMessage(message, key:  flag.id()+to, flag: flag, success: false)
    }
    
    func onFlagReceiving(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        let message = "Downloading \(flag.type())"
        preMessage(message, key: flag.id(), flag: flag)
    }
    
    func onFlagReceiveSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        let from = note.userInfo!["from"] as! String
        let message = "Downloaded \(flag.type()) from \(from)"
        postMessage(message, key:  flag.id(), flag: flag, success: true)
    }
    
    func onFlagReceiveFailed(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        let message = "Failed downloading \(flag.type())"
        postMessage(message, key:  flag.id(), flag: flag, success: false)
    }
    
    func onAccepting(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Sending accept for \(flag.type())"
            preMessage(message, key: flag.id(), flag: flag)
        }
    }
    
    func onAcceptSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Sent accept"
            postMessage(message, key:  flag.id(), flag: flag, success: true)
        }
    }
    
    func onAcceptFailed(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Failed sending accept"
            postMessage(message, key:  flag.id(), flag: flag, success: false)
        }
    }
    
    func onDeclining(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Sending decline for \(flag.type())"
            preMessage(message, key: flag.id(), flag: flag)
        }
    }
    
    func onDeclineSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Sent decline"
            postMessage(message, key:  flag.id(), flag: flag, success: true)
        }
    }
    
    func onDeclineFailed(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Failed sending decline"
            postMessage(message, key:  flag.id(), flag: flag, success: false)
        }
    }
    
    func onAckReceiveSuccess(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let from = note.userInfo!["from"] as! String
            let inviteeState = flag.findInvitee(from)?.state()
            let accepted = inviteeState == InviteeState.Accepted || inviteeState == InviteeState.Accepting
            let message = "\(from) \(accepted ? "accepted" : "declined") \(flag.summary())"
            postMessage(message, key:  flag.id(), flag: flag, success: accepted)
        }
    }

    func onNameTaken(note: NSNotification) {
        Utils.runOnUiThread {
            let takenName = note.userInfo!["name"]
            self.showMessage("Sharing name \(takenName!) taken!", color: UIColor.redColor(), fontColor: UIColor.whiteColor(), time: 3.0)
            self.mapController.ensureUserKnown()
        }
    }
    
    func onNameAccepted(note: NSNotification) {
        Utils.runOnUiThread {
            let name = note.userInfo!["name"]
            self.showMessage("Weclome to Backmap \(name!)", color: UIColor.greenColor(), fontColor: UIColor.blackColor(), time: 3.0)
        }
    }
    
    func onEventListChange(note: NSNotification) {
        Utils.runOnUiThread {
            let enable = note.userInfo!["enable"] as! Bool
            self.mapController.alarmButton.hidden = !enable
        }
    }
    
    func onBackupPreparing(note: NSNotification) {
        let message = "Preparing backup"
        preMessage(message, key: "backup", color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8))
    }
    
    func onBackupPrepared(note: NSNotification) {
        dismissMessage("backup")
    }
    
    private func preMessage(message: String, key: String, flag: Flag) {
        let color = CategoryController.getColorForCategory(flag.type())
        preMessage(message, key: key, color: color)
    }
    
    private func preMessage(message: String, key: String, color: UIColor) {
        Utils.runOnUiThread {
            let modal = self.showMessage(message, color: color, time: nil)
            self.dismissMessage(key)
            self.activeModals[key] = modal
        }
    }
    
    private func postMessage(message: String, key: String, flag: Flag, success: Bool) {
        Utils.delay(0.5) {
            let color = success ? UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0) : UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
            self.dismissMessage(key)
            self.showMessage(message, color: color, time: 2)
        }
    }
    
    private func dismissMessage(key: String) {
        if let existingModal = self.activeModals[key] {
            self.activeModals.removeValueForKey(key)
            self.dismissMessage(existingModal)
        }
    }
    
    private func showMessage(text: String, color: UIColor, time: Double?) -> Modal {
        return self.showMessage(text, color: color, fontColor: UIColor.blackColor(), time: time)
    }
    
    private func showMessage(text: String, color: UIColor, fontColor: UIColor, time: Double?) -> Modal {
        let messageModal = Modal(viewName: "MessageView", owner: mapController)
        let message = messageModal.findElementByTag(1) as! UIButton
        message.backgroundColor = color.colorWithAlphaComponent(1)
        message.setTitleColor(fontColor, forState: UIControlState.Normal)
        message.setTitle(text, forState: UIControlState.Normal)
        messageModal.slideDownFromTop(self.mapController.view)
        
        if time != nil {
            Utils.delay(time!) {
                messageModal.slideUpFromTop(self.mapController.view)
            }
        }
        return messageModal
    }
    
    private func dismissMessage(messageModal: Modal) {
        messageModal.slideUpFromTop(self.mapController.view)
    }
    
    private func dismissMessage(sender: AnyObject?) {
        let messageModal = self.messageModals.removeLast()
        messageModal.slideUpFromTop(self.mapController.view)
    }
}