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
        
        print("Receive triggered")
        
        shareRoot(Global.getUser().getName()).observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.receiveNextFlag(snapshot.children)
        })
    }
    
    private func receiveNextFlag(firebaseFlags:NSEnumerator) {
        let firebaseFlag = firebaseFlags.nextObject() as? FDataSnapshot
        if firebaseFlag != nil {
            self.receive(firebaseFlag!, onComplete: {
                self.receiveNextFlag(firebaseFlags)
            })
        }
    }
    
    func receive(firebaseFlag: FDataSnapshot, onComplete: () -> ()) {
        let encoded = firebaseFlag.value["memory"] as! String
        let from = firebaseFlag.value["from"] as! String
        let flag = Flag.decode(encoded)
        
        print("Received flag \(flag.type())")

        flagRepository.receive(from, to: Global.getUser().getName(), flag: flag,
            onNew: { newFlag in
                self.downloadImages(newFlag, onComplete: {
                    do {
                        try newFlag.receiveNewSuccess()
                        print("All new flag photos downloaded. ")
                        self.flagRepository.add(newFlag)
                        firebaseFlag.ref.removeValue()
                        onComplete()
                        Utils.notifyObservers("FlagReceiveSuccess", properties: ["flag": newFlag, "from": from])
                    } catch {
                        flag.kill()
                        firebaseFlag.ref.removeValue()
                        onComplete()
                        Utils.notifyObservers("FlagReceiveFailed", properties: ["flag": newFlag, "from": from])
                    }
                })
            },
            onUpdate: { updatedFlag in
                self.downloadImages(updatedFlag, onComplete: {
                    do {
                        try updatedFlag.receiveUpdateSuccess()
                        print("All udated flag photos downloaded. ")
                        firebaseFlag.ref.removeValue()
                        onComplete()
                        Utils.notifyObservers("FlagReceiveSuccess", properties: ["flag": updatedFlag, "from": from])
                    } catch {
                        updatedFlag.reset(FlagState.Neutral)
                        firebaseFlag.ref.removeValue()
                        onComplete()
                        Utils.notifyObservers("FlagReceiveFailed", properties: ["flag": updatedFlag, "from": from])
                    }
                })
            },
            onAck: { ackedFlag in
                print("Ack processed. ")
                firebaseFlag.ref.removeValue()
                onComplete()
                if ackedFlag != nil {
                    Utils.notifyObservers("AckReceiveSuccess", properties: ["flag": ackedFlag!, "from": from])
                }
            }
        )
    }

    private func completeReceive(flag: Flag) {
        print("Completed receiving flag \(flag.type())")

    }

    private func downloadImages(flag: Flag, onComplete: () -> ()) {
        print("Downloading shared images for flag \(flag.id())")
        
        let imageUrls = photoAlbum.getFlagImageUrls(flag.id())
        var leftToDownload = imageUrls.count
        
        for imageUrl in imageUrls {
            let readRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
            readRequest.bucket = BUCKET
            readRequest.key =  imageUrl.lastPathComponent!
            let downloadingurl = NSURL(fileURLWithPath: "\(imageUrl.path!).recent")
            readRequest.downloadingFileURL = downloadingurl
            
            let task = transferManager.download(readRequest)
            task.continueWithBlock { (task) -> AnyObject! in
                self.postPhotoDownload(imageUrl.lastPathComponent!, imageUrl: downloadingurl, task: task)
                leftToDownload--
                if leftToDownload == 0 {
                    onComplete()
                }
                return nil
            }
        }
    }
    
    private func postPhotoDownload(key: String, imageUrl: NSURL, task: BFTask) {
        if task.error != nil {
            // ensure no partial file left
//            do {
//                try photoAlbum.fileManager.removeItemAtPath(imageUrl.path!)
//            } catch {
//            }
        } else {
            print("    Image downloaded \(imageUrl.lastPathComponent!)")
            let deleteRequest = AWSS3DeleteObjectRequest()
            deleteRequest.bucket = BUCKET
            deleteRequest.key =  key
            AWSS3.defaultS3().deleteObject(deleteRequest).continueWithBlock{ _ in return nil }
        }
    }
    
    private func shareRoot(to: String) -> Firebase {
        return root.childByAppendingPath("users/" + to + "/given")
    }
}