//
//  OutBox.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class OutBox {
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
    
    func send() {
        print("SENDING...")
        sendInvites()
        sendAccepts()
        sendDeclines()
    }
    
    private func sendInvites() {
        for flag in flagRepository.flags() {
            let inviting = flag.invitees().filter {$0.state() == InviteeState.Inviting}
            for invitee in inviting {
                invite(invitee, flag: flag)
            }
        }
    }
    
    private func sendAccepts() {
        let accepting = flagRepository.flags().filter {$0.state() == FlagState.AcceptingNew}
        for flag in accepting {
            print("Accepting \(flag.type())")
            self.uploadFlagDetails(flag.originator(), flag: flag)
            do {
                try flag.acceptNewSuccess()
            } catch {
                flag.reset(FlagState.Neutral)
            }
        }
    }
    
    private func sendDeclines() {
        let declining = flagRepository.flags().filter {$0.state() == FlagState.DecliningNew}
        for flag in declining {
            print("Declining \(flag.type())")
            self.uploadFlagDetails(flag.originator(), flag: flag)
            do {
                try flag.declineNewSuccess()
            } catch {
                flag.reset(FlagState.Neutral)
            }
        }
    }
    
    func invite(invitee: Invitee2, flag: Flag) {
        Utils.notifyObservers("Inviting", properties: ["name": invitee.name(), "flag": flag])
        uploadPhotos(invitee, flag: flag,
            onComplete: {
                self.uploadFlagDetails(invitee.name(), flag: flag)
                invitee.invitingSuccess()
            },
            onError: {
                invitee.invitingFailure()
                // hint failed
            })
    }
    
    private func uploadPhotos(invitee: Invitee2, flag: Flag, onComplete: () -> Void, onError: () -> Void) {
        let photos = photoAlbum.photos(flag)
        print("Uploading \(photos.count) photos")
        var leftToUpload = photos.count
        var failedToUpload = 0
        if photos.count > 0 {
            for photo in photos {
                let key = (photo.imagePath as NSString).lastPathComponent
                print("    Uploading photo \(key)")
                uploadImage(photo.imagePath, key: key,
                    onComplete: {
                        leftToUpload--
                        print("    Uploaded photo '\(photo.imagePath)'.  \(leftToUpload) left")
                        self.postPhotoUpload(leftToUpload, failedToUpload: failedToUpload, onComplete: onComplete, onError: onError)
                    },
                    onError: {
                        leftToUpload--
                        failedToUpload++
                        print("    Failed uploading photo '\(photo.imagePath)'.  \(leftToUpload) left")
                        self.postPhotoUpload(leftToUpload, failedToUpload: failedToUpload, onComplete: onComplete, onError: onError)
                    })
            }
        } else {
            onComplete()
        }
    }
    
    private func postPhotoUpload(leftToUpload: Int, failedToUpload: Int, onComplete: () -> Void, onError: () -> Void) {
        if leftToUpload == 0 {
            if failedToUpload == 0 {
                onComplete()
            } else {
                onError()
            }
        }
    }
    
    private func uploadImage(imagePath: String?, key: String, onComplete: () -> Void, onError: () -> Void) {
        let uploadRequest : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = BUCKET
        uploadRequest.key = key
        uploadRequest.body = NSURL(fileURLWithPath: imagePath!)
        uploadRequest.ACL = AWSS3ObjectCannedACL.AuthenticatedRead
        
        let task = transferManager.upload(uploadRequest)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("    Umage upload FAILED! \(key)")
                onError()
            } else {
                print("    Image uploaded \(key)")
                onComplete()
            }
            
            return nil
        }
    }
    
    private func uploadFlagDetails(to: String, flag: Flag) {
        print("FIREBASE OP: Uploading flag " + flag.encode())
        let newNode = shareRoot(to).childByAutoId()
        newNode.setValue(["from": Global.getUser().getName(), "memory": flag.encode()])
        // todo - handle failure
        
        Utils.notifyObservers("FlagSent", properties: ["flag": flag])
    }
    
    private func shareRoot(to: String) -> Firebase {
        return root.childByAppendingPath("users/" + to + "/given")
    }

}