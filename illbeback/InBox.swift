//
//  InBox.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import AWSS3

class InBox {
    fileprivate let flagRepository: FlagRepository
    fileprivate let photoAlbum: PhotoAlbum
    fileprivate var root: Firebase
    fileprivate let BUCKET = "illbebackappus"
    fileprivate var transferManager: AWSS3TransferManager
    fileprivate static var deviceToken: Data?
    fileprivate var receiving = false
    
    init(flagRepository: FlagRepository, photoAlbum: PhotoAlbum) {
        self.flagRepository = flagRepository
        self.photoAlbum = photoAlbum
        root = Firebase(url:"https://illbeback.firebaseio.com/")
        transferManager = AWSS3TransferManager.default()
    }
    
    func isReceiving() -> Bool {
        return receiving
    }
    
    func receive() {
        if !Global.getUser().hasName() {
            return
        }
        
        print("Receive triggered")
        
        shareRoot(Global.getUser().getName()).observeSingleEvent(of: .value, with: { snapshot in
            self.receiveNextFlag((snapshot?.children)!)
        })
    }
    
    fileprivate func receiveNextFlag(_ firebaseFlags:NSEnumerator) {
        receiving = true
        let firebaseFlag = firebaseFlags.nextObject() as? FDataSnapshot
        if firebaseFlag != nil {
            self.receive(firebaseFlag!, onComplete: {
                self.receiveNextFlag(firebaseFlags)
            })
        } else {
            receiving = false
        }
    }
    
    func receive(_ firebaseFlag: FDataSnapshot, onComplete: @escaping () -> ()) {
        let encoded = (firebaseFlag.value as! NSDictionary)["memory"] as! String
        let from = (firebaseFlag.value as! NSDictionary)["from"] as! String
        let flag = Flag.decode(encoded)
        
        print("Received flag \(flag.type())")

        flagRepository.receive(from, to: Global.getUser().getName(), flag: flag,
            onNew: { newFlag in
                self.downloadImages(newFlag, onComplete: {
                    do {
                        try newFlag.receiveNewSuccess()
                        print("All new flag photos downloaded. ")
                        self.flagRepository.create(newFlag)
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

    fileprivate func completeReceive(_ flag: Flag) {
        print("Completed receiving flag \(flag.type())")

    }

    fileprivate func downloadImages(_ flag: Flag, onComplete: @escaping () -> ()) {
        print("Downloading shared images for flag \(flag.id())")
        
        let imageUrls = photoAlbum.getFlagImageUrls(flag.id())
        var leftToDownload = imageUrls.count
        
        for imageUrl in imageUrls {
            let readRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
            readRequest.bucket = BUCKET
            readRequest.key =  imageUrl.lastPathComponent
            let downloadingurl = URL(fileURLWithPath: "\(imageUrl.path).recent")
            readRequest.downloadingFileURL = downloadingurl
            
            let task = transferManager.download(readRequest)
            task!.continue( { (task) -> AnyObject! in
                self.postPhotoDownload(imageUrl.lastPathComponent, imageUrl: downloadingurl, task: task)
                leftToDownload = leftToDownload - 1
                if leftToDownload == 0 {
                    onComplete()
                }
                return nil
            })
        }
    }
    
    fileprivate func postPhotoDownload(_ key: String, imageUrl: URL, task: AWSTask<AnyObject>) {
        if task.error != nil {
            // ensure no partial file left
//            do {
//                try photoAlbum.fileManager.removeItemAtPath(imageUrl.path!)
//            } catch {
//            }
        } else {
            print("    Image downloaded \(imageUrl.lastPathComponent)")
            let deleteRequest = AWSS3DeleteObjectRequest()
            deleteRequest?.bucket = BUCKET
            deleteRequest?.key =  key
            AWSS3.default().deleteObject(deleteRequest!).continue({ _ in return nil })
        }
    }
    
    fileprivate func shareRoot(_ to: String) -> Firebase {
        return root.child(byAppendingPath: "users/" + to + "/given")
    }
}
