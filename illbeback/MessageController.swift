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
    }
    
    func onFlagSending(note: NSNotification) {
        Utils.runOnUiThread {
            let flag = note.userInfo!["flag"] as! Flag
            let to = note.userInfo!["to"] as! String
            
            let title = "Sending \(flag.type()) to \(to)"
            let color = CategoryController.getColorForCategory(flag.type())
            let modal = self.showMessage(title, color: color, time: nil)
            self.activeModals[flag.id()+to] = modal
        }
    }
    
    func onFlagSendSuccess(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            let to = note.userInfo!["to"] as! String
            
            let title = "Sent \(flag.type()) to \(to)"
            let color = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)
            if let sendingModal = self.activeModals[flag.id()+to] {
                self.activeModals.removeValueForKey(flag.id()+to)
                self.dismissMessage(sendingModal)
            }
            
            self.showMessage(title, color: color, time: 2)
        }
    }
    
    func onFlagSendFailed(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            let to = note.userInfo!["to"] as! String
            
            let title = "Failed sending \(flag.type()) to \(to)"
            let color = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
            if let sendingModal = self.activeModals[flag.id()+to] {
                self.activeModals.removeValueForKey(flag.id()+to)
                self.dismissMessage(sendingModal)
            }
            
            self.showMessage(title, color: color, time: 2)
        }
    }
    
    func onFlagReceiving(note: NSNotification) {
        Utils.runOnUiThread {
            let flag = note.userInfo!["flag"] as! Flag
            
            let title = "Downloading \(flag.type())"
            let color = CategoryController.getColorForCategory(flag.type())
            let modal = self.showMessage(title, color: color, time: nil)
            self.activeModals[flag.id()] = modal
        }
    }
    
    func onFlagReceiveSuccess(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            let from = note.userInfo!["from"] as! String
            
            let title = "Downloaded \(flag.type()) from \(from)"
            let color = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)
            if let receivingModal = self.activeModals[flag.id()] {
                self.activeModals.removeValueForKey(flag.id())
                self.dismissMessage(receivingModal)
            }
            
            self.showMessage(title, color: color, time: 2)
        }
    }
    
    func onAckReceiveSuccess(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            if flag.isEvent() {
                let from = note.userInfo!["from"] as! String
                
                let inviteeState = flag.findInvitee2(Global.getUser().getName())?.state()
                let accepted = inviteeState == InviteeState.Accepted || inviteeState == InviteeState.Accepting
                let title = "\(from) \(accepted ? "accepted" : "declined") \(flag.summary())"
                let color = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)
                
                self.showMessage(title, color: color, time: 2)
            }
        }
    }
    
    func onFlagReceiveFailed(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            
            let title = "Failed downloading \(flag.type())"
            let color = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
            if let receivingModal = self.activeModals[flag.id()] {
                self.activeModals.removeValueForKey(flag.id())
                self.dismissMessage(receivingModal)
            }
            
            self.showMessage(title, color: color, time: 2)
        }
    }
    
    func onAccepting(note: NSNotification) {
        Utils.runOnUiThread {
            let flag = note.userInfo!["flag"] as! Flag

            if flag.isEvent() {
                let title = "Sending accept for \(flag.type())"
                let color = CategoryController.getColorForCategory(flag.type())
                let modal = self.showMessage(title, color: color, time: nil)
                self.activeModals[flag.id()] = modal
            }
        }
    }
    
    func onAcceptSuccess(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            
            if flag.isEvent() {
                let title = "Sent accept"
                let color = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)
                if let receivingModal = self.activeModals[flag.id()] {
                    self.activeModals.removeValueForKey(flag.id())
                    self.dismissMessage(receivingModal)
                }
                
                self.showMessage(title, color: color, time: 2)
            }
        }
    }
    
    func onAcceptFailed(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            
            if flag.isEvent() {
                let title = "Failed sending accept"
                let color = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
                if let receivingModal = self.activeModals[flag.id()] {
                    self.activeModals.removeValueForKey(flag.id())
                    self.dismissMessage(receivingModal)
                }
                
                self.showMessage(title, color: color, time: 2)
            }
        }
    }
    
    func onDeclining(note: NSNotification) {
        Utils.runOnUiThread {
            let flag = note.userInfo!["flag"] as! Flag
            
            if flag.isEvent() {
                let title = "Sending decline for \(flag.type())"
                let color = CategoryController.getColorForCategory(flag.type())
                let modal = self.showMessage(title, color: color, time: nil)
                self.activeModals[flag.id()] = modal
            }
        }
    }
    
    func onDeclineSuccess(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            
            if flag.isEvent() {
                let title = "Sent decline"
                let color = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)
                if let receivingModal = self.activeModals[flag.id()] {
                    self.activeModals.removeValueForKey(flag.id())
                    self.dismissMessage(receivingModal)
                }
                
                self.showMessage(title, color: color, time: 2)
            }
        }
    }
    
    func onDeclineFailed(note: NSNotification) {
        Utils.delay(0.5) {
            let flag = note.userInfo!["flag"] as! Flag
            
            if flag.isEvent() {
                let title = "Failed sending decline"
                let color = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
                if let receivingModal = self.activeModals[flag.id()] {
                    self.activeModals.removeValueForKey(flag.id())
                    self.dismissMessage(receivingModal)
                }
                
                self.showMessage(title, color: color, time: 2)
            }
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
    
    func showMessage(text: String, color: UIColor, time: Double?) -> Modal {
        return self.showMessage(text, color: color, fontColor: UIColor.blackColor(), time: time)
    }
    
    func showMessage(text: String, color: UIColor, fontColor: UIColor, time: Double?) -> Modal {
        let messageModal = Modal(viewName: "MessageView", owner: mapController)
        let message = messageModal.findElementByTag(1) as! UIButton
        message.backgroundColor = color.colorWithAlphaComponent(1)
        message.setTitleColor(fontColor, forState: UIControlState.Normal)
        message.setTitle(text, forState: UIControlState.Normal)
        Utils.runOnUiThread {
            messageModal.slideDownFromTop(self.mapController.view)
        }
        
        if time != nil {
            Utils.delay(time!) {
                messageModal.slideUpFromTop(self.mapController.view)
            }
        }
        return messageModal
    }
    
    func dismissMessage(messageModal: Modal) {
        Utils.runOnUiThread() {
            messageModal.slideUpFromTop(self.mapController.view)
        }
    }
    
    func dismissMessage(sender: AnyObject?) {
        Utils.runOnUiThread() {
            let messageModal = self.messageModals.removeLast()
            messageModal.slideUpFromTop(self.mapController.view)
        }
    }
}