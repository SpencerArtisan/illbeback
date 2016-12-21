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
    fileprivate var mapController: MapController
    fileprivate var flagRepository: FlagRepository
    fileprivate var photoAlbum: PhotoAlbum
    
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
                self.mapController.present(mailComposeViewController, animated: true, completion: {})
            } else {
                print("MAIL SEND FAILED")
            }
            Utils.notifyObservers("BackupPrepared", properties: [:])
        }
    }
    
    func mailComposer() -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject("Breadcrumb backup")
        mailComposer.setMessageBody("This email is your backup.  Fill in the To field.  You probably want to send it to yourself.\r\n\r\nTo restore the backup, click on the attachment and choose 'Copy to Breadcrumb'.", isHTML: false)
//        let data = exportToData()
//        mailComposer.addAttachmentData(data, mimeType: "application/breadcrumbs", fileName: "bread.crumb")
        return mailComposer
    }
    
//    func exportToData() -> Data {
//        let flagData = Data.with(contentsOfFile: flagRepository.filePath()) as! Data
//        
//        let data = NSMutableData()
//        let archiver = NSKeyedArchiver.init(forWritingWith: data)
//        archiver.encode(Global.getUser().getName(), forKey: "user")
//        archiver.encode(flagData, forKey: "flags")
//        let imageFiles = photoAlbum.allImageFiles()
//        imageFiles.forEach {imageFile in
//            let image = UIImage(contentsOfFile: imageFile)
//            if image != nil {
//                let imageData = UIImageJPEGRepresentation(image!, 0.25)!
//                let key = URL(fileURLWithPath: imageFile).lastPathComponent
//                print("Encoding image with key \(key)")
//                archiver.encode(imageData, forKey: key)
//            }
//        }
//        archiver.finishEncoding()
//        return data as Data
//    }
    
    func importFromURL(_ url: URL) {

        let data = try! Data(contentsOf: url)
        let unarchiver = NSKeyedUnarchiver.init(forReadingWith: data)
        let user = unarchiver.decodeObject(forKey: "user") as! String
        Global.setUserName(user, allowOverwrite: true)
        let flagData = unarchiver.decodeObject(forKey: "flags") as! Data
        flagRepository.removeAll()
        try? flagData.write(to: URL(fileURLWithPath: flagRepository.filePath()) , options: [.atomic])
        flagRepository.read()
        
        mapController.hintControlller.backupRestoringHint()

        Utils.delay(0.5) {
        self.flagRepository.flags().forEach { flag in
            print("Reading images for flag \(flag.id())")
            let flagUrls = self.photoAlbum.getFlagImageUrls(flag.id())
            flagUrls.forEach { url in
                let lastPathComp = url.lastPathComponent
                print("Looking for image \(lastPathComp)")
                let imageData = unarchiver.decodeObject(forKey: lastPathComp) as? Data
                if imageData != nil {
                    print("Image exists.  Saving to album at path \(url.path)")
                    FileManager.default.createFile(atPath: url.path, contents: imageData!, attributes: nil)
                }
            }
        }
        
        self.mapController.hintControlller.backupRestoredHint()
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
