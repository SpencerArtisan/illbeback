//
//  MessageController.swift
//  illbeback
//
//  Created by Spencer Ward on 07/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class MessageController : NSObject {
    fileprivate var mapController: MapController!
    fileprivate var activeModals = [String: Modal] ()
    fileprivate var messageModals: [Modal] = []
    
    init(mapController: MapController) {
        super.init()
        self.mapController = mapController
        Utils.addObserver(self, selector: #selector(MessageController.onNameTaken), event: "NameTaken")
        Utils.addObserver(self, selector: #selector(MessageController.onNameAccepted), event: "NameAccepted")
        Utils.addObserver(self, selector: #selector(MessageController.onEventListChange), event: "EventListChange")
        Utils.addObserver(self, selector: #selector(MessageController.onFlagSending), event: "FlagSending")
        Utils.addObserver(self, selector: #selector(MessageController.onFlagSendSuccess), event: "FlagSendSuccess")
        Utils.addObserver(self, selector: #selector(MessageController.onFlagSendFailed), event: "FlagSendFailed")
        Utils.addObserver(self, selector: #selector(MessageController.onFlagReceiving), event: "FlagReceiving")
        Utils.addObserver(self, selector: #selector(MessageController.onFlagReceiveSuccess), event: "FlagReceiveSuccess")
        Utils.addObserver(self, selector: #selector(MessageController.onFlagReceiveFailed), event: "FlagReceiveFailed")
        Utils.addObserver(self, selector: #selector(MessageController.onAckReceiveSuccess), event: "AckReceiveSuccess")
        Utils.addObserver(self, selector: #selector(MessageController.onDeclining), event: "Declining")
        Utils.addObserver(self, selector: #selector(MessageController.onDeclineSuccess), event: "DeclineSuccess")
        Utils.addObserver(self, selector: #selector(MessageController.onDeclineFailed), event: "DeclineFailed")
        Utils.addObserver(self, selector: #selector(MessageController.onAccepting), event: "Accepting")
        Utils.addObserver(self, selector: #selector(MessageController.onAcceptSuccess), event: "AcceptSuccess")
        Utils.addObserver(self, selector: #selector(MessageController.onAcceptFailed), event: "AcceptFailed")
        Utils.addObserver(self, selector: #selector(MessageController.onBackupPreparing), event: "BackupPreparing")
        Utils.addObserver(self, selector: #selector(MessageController.onBackupPrepared), event: "BackupPrepared")
    }
    
    func onFlagSending(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        let to = note.userInfo!["to"] as! String
        let message = "Sending \(flag.type()) to \(to)"
        preMessage(message, key: flag.id()+to, flag: flag)
    }
    
    func onFlagSendSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        let to = note.userInfo!["to"] as! String
        let message = "Sent \(flag.type()) to \(to)"
        postMessage(message, key:  flag.id()+to, flag: flag, success: true)
    }
    
    func onFlagSendFailed(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        let to = note.userInfo!["to"] as! String
        let message = "Failed sending \(flag.type()) to \(to)"
        postMessage(message, key:  flag.id()+to, flag: flag, success: false)
    }
    
    func onFlagReceiving(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        let message = "Downloading \(flag.type())"
        preMessage(message, key: flag.id(), flag: flag)
    }
    
    func onFlagReceiveSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        let from = note.userInfo!["from"] as! String
        let message = "Downloaded \(flag.type()) from \(from)"
        postMessage(message, key:  flag.id(), flag: flag, success: true)
    }
    
    func onFlagReceiveFailed(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        let message = "Failed downloading \(flag.type())"
        postMessage(message, key:  flag.id(), flag: flag, success: false)
    }
    
    func onAccepting(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Sending accept for \(flag.type())"
            preMessage(message, key: flag.id(), flag: flag)
        }
    }
    
    func onAcceptSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Sent accept"
            postMessage(message, key:  flag.id(), flag: flag, success: true)
        }
    }
    
    func onAcceptFailed(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Failed sending accept"
            postMessage(message, key:  flag.id(), flag: flag, success: false)
        }
    }
    
    func onDeclining(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Sending decline for \(flag.type())"
            preMessage(message, key: flag.id(), flag: flag)
        }
    }
    
    func onDeclineSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Sent decline"
            postMessage(message, key:  flag.id(), flag: flag, success: true)
        }
    }
    
    func onDeclineFailed(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let message = "Failed sending decline"
            postMessage(message, key:  flag.id(), flag: flag, success: false)
        }
    }
    
    func onAckReceiveSuccess(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        if flag.isEvent() {
            let from = note.userInfo!["from"] as! String
            let inviteeState = flag.findInvitee(from)?.state()
            let declined = inviteeState == InviteeState.Declined || inviteeState == InviteeState.Declining
            let message = "\(from) \(declined ? "declined" : "accepted" ) \(flag.summary())"
            postMessage(message, key:  flag.id(), flag: flag, success: !declined)
        }
    }

    func onNameTaken(_ note: Notification) {
        Utils.runOnUiThread {
            let takenName = note.userInfo!["name"]
            self.showMessage("Sharing name \(takenName!) taken!", color: UIColor.red, fontColor: UIColor.white, time: 3.0)
            self.mapController.ensureUserKnown()
        }
    }
    
    func onNameAccepted(_ note: Notification) {
        Utils.runOnUiThread {
            let name = note.userInfo!["name"]
            self.showMessage("Welcome to Breadsrumbs \(name!)", color: UIColor.green, fontColor: UIColor.black, time: 3.0)
        }
        
        Utils.delay(8) {
            self.mapController.hintControlller.photoHint()
        }
    }
    
    func onEventListChange(_ note: Notification) {
        Utils.runOnUiThread {
            let enable = note.userInfo!["enable"] as! Bool
            self.mapController.alarmButton.isHidden = !enable
        }
    }
    
    func onBackupPreparing(_ note: Notification) {
        let message = "Preparing backup"
        preMessage(message, key: "backup", color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8))
    }
    
    func onBackupPrepared(_ note: Notification) {
        Utils.runOnUiThread {
            self.dismissMessage("backup")
        }
    }
    
    fileprivate func preMessage(_ message: String, key: String, flag: Flag) {
        let color = CategoryController.getColorForCategory(flag.type())
        preMessage(message, key: key, color: color)
    }
    
    fileprivate func preMessage(_ message: String, key: String, color: UIColor) {
        Utils.runOnUiThread {
            self.dismissMessage(key)
            let modal = self.showMessage(message, color: color, time: nil)
            self.activeModals[key] = modal
        }
    }
    
    fileprivate func postMessage(_ message: String, key: String, flag: Flag, success: Bool) {
        Utils.delay(0.5) {
            let color = success ? UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0) : UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
            self.dismissMessage(key)
            self.showMessage(message, color: color, time: 2)
        }
    }
    
    fileprivate func dismissMessage(_ key: String) {
        if let existingModal = self.activeModals[key] {
            self.activeModals.removeValue(forKey: key)
            self.dismissMessage(existingModal)
        }
    }
    
    fileprivate func showMessage(_ text: String, color: UIColor, time: Double?) -> Modal {
        return self.showMessage(text, color: color, fontColor: UIColor.black, time: time)
    }
    
    fileprivate func showMessage(_ text: String, color: UIColor, fontColor: UIColor, time: Double?) -> Modal {
        let messageModal = Modal(viewName: "MessageView", owner: mapController)
        let message = messageModal.findElementByTag(1) as! UIButton
        message.backgroundColor = color.withAlphaComponent(1)
        message.setTitleColor(fontColor, for: UIControlState())
        message.setTitle(text, for: UIControlState())
        messageModal.slideDownFromTop(self.mapController.view)
        
        if time != nil {
            Utils.delay(time!) {
                messageModal.slideUpFromTop(self.mapController.view)
            }
        }
        return messageModal
    }
    
    fileprivate func dismissMessage(_ messageModal: Modal) {
        messageModal.slideUpFromTop(self.mapController.view)
    }
    
    fileprivate func dismissMessage(_ sender: AnyObject?) {
        let messageModal = self.messageModals.removeLast()
        messageModal.slideUpFromTop(self.mapController.view)
    }
}
