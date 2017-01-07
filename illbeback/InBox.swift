//
//  InBox.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import AWSS3
import FirebaseDatabase

class InBox {
    fileprivate let flagRepository: FlagRepository
    fileprivate let photoAlbum: PhotoAlbum
    fileprivate var root: FIRDatabaseReference
    fileprivate let BUCKET = "ireland-breadcrumbs"
    fileprivate var transferManager: AWSS3TransferUtility
    fileprivate static var deviceToken: Data?
    fileprivate var receiving = false
    
    init(flagRepository: FlagRepository, photoAlbum: PhotoAlbum) {
        self.flagRepository = flagRepository
        self.photoAlbum = photoAlbum
        root = FIRDatabase.database().reference(fromURL: "https://illbeback.firebaseio.com/")
        transferManager = AWSS3TransferUtility.s3TransferUtility(forKey: "x")
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
            self.receiveNextFlag(snapshot.children)
        })
    }
    
    fileprivate func receiveNextFlag(_ firebaseFlags:NSEnumerator) {
        receiving = true
        let firebaseFlag = firebaseFlags.nextObject() as? FIRDataSnapshot
        if firebaseFlag != nil {
            self.receive(firebaseFlag!, onComplete: {
                self.receiveNextFlag(firebaseFlags)
            })
        } else {
            receiving = false
        }
    }
    
    func receive(_ firebaseFlag: FIRDataSnapshot, onComplete: @escaping () -> ()) {
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
                        updatedFlag.reset()
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
            let urlFixed = imageUrl
            let url = URL(string: "https://s3-eu-west-1.amazonaws.com/ireland-breadcrumbs/\(imageUrl.lastPathComponent)")
            print("Trying to download image \(url!)")
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                self.onPhotoDownload(data: data, response: response, error: error, imageUrl: urlFixed)
                leftToDownload = leftToDownload - 1
                if leftToDownload == 0 {
                    onComplete()
                }
            }
            
            task.resume()
        }
    }
    
    fileprivate func onPhotoDownload(data: Data?, response: URLResponse?, error: Error?, imageUrl: URL) {
        if error == nil && data != nil && data!.count > 1000 {
            let downloadingurl = URL(fileURLWithPath: "\(imageUrl.path).recent")
            print("Image download complete. Saving to file \(downloadingurl.path)")
            FileManager.default.createFile(atPath: downloadingurl.path, contents: data!, attributes: nil)
            let deleteRequest = AWSS3DeleteObjectRequest()
            deleteRequest?.bucket = self.BUCKET
            deleteRequest?.key =  imageUrl.lastPathComponent
            print("Deleting \(imageUrl.lastPathComponent)")
            AWSS3.default().deleteObject(deleteRequest!)  { (output, error) in
                if  error != nil {
                    print("    Delete s3 photo FAILED! \(imageUrl.lastPathComponent): \(error)")
                } else {
                    print("    Delete s3 photo Success. \(imageUrl.lastPathComponent)")
                }
            }
        } else if error != nil {
            print("Error to downloading image \(response?.url)")
        } else {
            print("Unknown problem downing image \(response?.url)")
        }
    }
    
    fileprivate func shareRoot(_ to: String) -> FIRDatabaseReference {
        return root.child("users/" + to + "/given")
    }
}
