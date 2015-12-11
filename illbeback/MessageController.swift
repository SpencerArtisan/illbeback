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
        Utils.addObserver(self, selector: "onFlagReceiveSuccess:", event: "FlagReceiveFailed")
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
        Utils.runOnUiThread {
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
        Utils.runOnUiThread {
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
        Utils.runOnUiThread {
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
    
    func onFlagReceiveFailed(note: NSNotification) {
        Utils.runOnUiThread {
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
        Utils.runOnUiThread() {
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