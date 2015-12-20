//
//  Backup.swift
//  illbeback
//
//  Created by Spencer Ward on 20/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class Backup: NSObject, MFMailComposeViewControllerDelegate {
    private var mapController: MapController
    
    init(mapController: MapController) {
        self.mapController = mapController
    }
    
    func create() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            mapController.presentViewController(mailComposeViewController, animated: true, completion: {})
        } else {
            print("MAIL SEND FAILED")
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["spencerkward@gmail.com"])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}