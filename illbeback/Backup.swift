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
    private var flagRepository: FlagRepository
    private var photoAlbum: PhotoAlbum
    
    init(mapController: MapController, flagRepository: FlagRepository, photoAlbum: PhotoAlbum) {
        self.mapController = mapController
        self.flagRepository = flagRepository
        self.photoAlbum = photoAlbum
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
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("Backmap backup")
        mailComposerVC.setMessageBody("This email is your backup.  Keep it somewhere safe!", isHTML: false)
        
        let flagData: NSData = NSData.dataWithContentsOfMappedFile(flagRepository.filePath()) as! NSData
        mailComposerVC.addAttachmentData(flagData, mimeType: "text/plain", fileName: "backmap.txt")

        let imageFiles = photoAlbum.allImageFiles()
        imageFiles.forEach {imageFIle in
            let imageData = UIImagePNGRepresentation(UIImage(contentsOfFile: imageFIle)!)
            mailComposerVC.addAttachmentData(imageData!, mimeType: "image/png", fileName: imageFIle)
        }
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}