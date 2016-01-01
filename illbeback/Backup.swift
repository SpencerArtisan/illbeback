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
        Utils.notifyObservers("BackupPreparing", properties: [:])
        Utils.delay(0.3) {
            let mailComposeViewController = self.mailComposer()
            if MFMailComposeViewController.canSendMail() {
                self.mapController.presentViewController(mailComposeViewController, animated: true, completion: {})
            } else {
                print("MAIL SEND FAILED")
            }
            Utils.notifyObservers("BackupPrepared", properties: [:])
        }
    }
    
    func mailComposer() -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject("Backmap backup")
        mailComposer.setMessageBody("This email is your backup.  Keep it somewhere safe!\r\nTo restore the backup, click on the attachment and choose 'Copy to Backmap'.", isHTML: false)
        let data = exportToData()
        mailComposer.addAttachmentData(data, mimeType: "application/backmap", fileName: "back.map")
        return mailComposer
    }
    
    func exportToData() -> NSData {
        let flagData = NSData.dataWithContentsOfMappedFile(flagRepository.filePath()) as! NSData
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver.init(forWritingWithMutableData: data)
        archiver.encodeObject(Global.getUser().getName(), forKey: "user")
        archiver.encodeObject(flagData, forKey: "flags")
        let imageFiles = photoAlbum.allImageFiles()
        imageFiles.forEach {imageFile in
            let imageData = UIImagePNGRepresentation(UIImage(contentsOfFile: imageFile)!)
            let key = NSURL(fileURLWithPath: imageFile).lastPathComponent!
            print("Encoding image with key \(key)")
            archiver.encodeObject(imageData, forKey: key)
        }
        archiver.finishEncoding()
        return data
    }
    
    func importFromURL(url: NSURL) {
        let data = NSData(contentsOfURL: url)!
        let unarchiver = NSKeyedUnarchiver.init(forReadingWithData: data)
        let user = unarchiver.decodeObjectForKey("user") as! String
        Global.setUserName(user, allowOverwrite: true)
        let flagData = unarchiver.decodeObjectForKey("flags") as! NSData
        flagRepository.removeAll()
        flagData.writeToFile(flagRepository.filePath() , atomically: true)
        flagRepository.read()
        
        flagRepository.flags().forEach { flag in
            print("Reading images for flag \(flag.id())")
            let flagUrls = photoAlbum.getFlagImageUrls(flag.id())
            flagUrls.forEach { url in
                let lastPathComp = url.lastPathComponent!
                print("Looking for image \(lastPathComp)")
                let imageData = unarchiver.decodeObjectForKey(lastPathComp) as? NSData
                if imageData != nil {
                    print("Image exists.  Saving to album at path \(url.path!)")
                    NSFileManager.defaultManager().createFileAtPath(url.path!, contents: imageData!, attributes: nil)
                }
            }
        }
        
        mapController.hintControlller.backupRestoredHint()
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}