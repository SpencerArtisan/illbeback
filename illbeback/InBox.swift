//
//  InBox.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class InBox {
    private let flagRepository: FlagRepository
    private let photoAlbum: PhotoAlbum
    private var root: Firebase
    private let BUCKET = "illbebackappus"
    private var transferManager: AWSS3TransferManager
    private static var deviceToken: NSData?
    
    init(flagRepository: FlagRepository, photoAlbum: PhotoAlbum) {
        self.flagRepository = flagRepository
        self.photoAlbum = photoAlbum
        root = Firebase(url:"https://illbeback.firebaseio.com/")
        transferManager = AWSS3TransferManager.defaultS3TransferManager()
    }
    
    func receive() {
        if !Global.getUser().hasName() {
            return
        }
        
        shareRoot(Global.getUser().getName()).observeSingleEventOfType(.Value, withBlock: { snapshot in
            let givenFlags = snapshot.children
            while let givenFlag: FDataSnapshot = givenFlags.nextObject() as? FDataSnapshot {
                self.receive(givenFlag)
            }
        })
    }
    
    func receive(givenFlag: FDataSnapshot) {
        let encoded = givenFlag.value["memory"] as! String
        let flag = Flag.decode(encoded)
        flagRepository.receive(flag,
            onNew: {
                self.downloadImages(flag, onComplete: {
                    print("All new flag photos downloaded.  Removing from firebase")
                    givenFlag.ref.removeValue()
                })
            },
            onUpdate: {
                self.downloadImages(flag, onComplete: {
                    print("All udated flag photos downloaded.  Removing from firebase")
                    givenFlag.ref.removeValue()
                })
            },
            onAck: {
                givenFlag.ref.removeValue()
            })
    }
    
    private func downloadImages(flag: Flag, onComplete: () -> Void) {
        print("Downloading shared images for flag \(flag.id())")
        
        let imageUrls = photoAlbum.getFlagImageUrls(flag.id())
        var leftToDownload = imageUrls.count
        
        for imageUrl in imageUrls {
            let readRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
            readRequest.bucket = BUCKET
            readRequest.key =  imageUrl.lastPathComponent!
            readRequest.downloadingFileURL = NSURL(fileURLWithPath: "\(imageUrl.path!).recent")
            
            let task = transferManager.download(readRequest)
            task.continueWithBlock { (task) -> AnyObject! in
                self.postPhotoDownload(imageUrl, task: task)
                leftToDownload--
                if leftToDownload == 0 {
                    onComplete()
                }
                return nil
            }
        }
    }
    
    private func postPhotoDownload(imageUrl: NSURL, task: BFTask) {
        if task.error != nil {
            // ensure no partial file left
            do {
                try photoAlbum.fileManager.removeItemAtPath(imageUrl.path!)
            } catch {
            }
        } else {
            print("    Image downloaded \(imageUrl.lastPathComponent!)")
        }
    }
    
    private func shareRoot(to: String) -> Firebase {
        return root.childByAppendingPath("users/" + to + "/given")
    }
    
}