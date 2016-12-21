//
//  OutBox.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class OutBox {
    fileprivate let flagRepository: FlagRepository
    fileprivate let photoAlbum: PhotoAlbum
    fileprivate var root: Firebase
    fileprivate let BUCKET = "illbebackappus"
    fileprivate var transferManager: AWSS3TransferManager
    fileprivate static var deviceToken: Data?
  
    init(flagRepository: FlagRepository, photoAlbum: PhotoAlbum) {
        self.flagRepository = flagRepository
        self.photoAlbum = photoAlbum
        root = Firebase(url:"https://illbeback.firebaseio.com/")
        transferManager = AWSS3TransferManager.default()
    }
    
    func send() {
        print("Send triggered")
        sendInvites()
        sendAccepts()
        sendDeclines()
    }
    
    fileprivate func sendAccepts() {
        for flag in flagRepository.flags() {
            let accepting = flag.invitees().filter {$0.state() == InviteeState.Accepting && $0.name() == Global.getUser().getName()}
            for invitee in accepting {
                print("SENDING ACCEPT for \(flag.type()) to \(flag.sender())...")
                Utils.notifyObservers("Accepting", properties: ["flag": flag])
                self.uploadFlagDetails(flag.sender()!, flag: flag,
                    onComplete: {
                        flag.acceptSuccess(invitee)
                        Utils.notifyObservers("AcceptSuccess", properties: ["flag": flag])
                    },
                    onError: {
                        flag.acceptFailure(invitee)
                        Utils.notifyObservers("AcceptFailed", properties: ["flag": flag])
                    }
                )
            }
        }
    }
    
    fileprivate func sendDeclines() {
        for flag in flagRepository.flags() {
            let declining = flag.invitees().filter {$0.state() == InviteeState.Declining && $0.name() == Global.getUser().getName()}
            for invitee in declining {
                print("SENDING DECLINE for \(flag.type()) to \(flag.sender())...")
                Utils.notifyObservers("Declining", properties: ["flag": flag])
                self.uploadFlagDetails(flag.sender()!, flag: flag,
                    onComplete: {
                        flag.declineSuccess(invitee)
                        Utils.notifyObservers("DeclineSuccess", properties: ["flag": flag])
                    },
                    onError: {
                        flag.declineFailure(invitee)
                        Utils.notifyObservers("DeclineFailed", properties: ["flag": flag])
                    }
                )
            }
        }
    }
    
    fileprivate func sendInvites() {
        for flag in flagRepository.flags() {
            let inviting = flag.invitees().filter {$0.state() == InviteeState.Inviting}
            for invitee in inviting {
                print("SENDING INVITE for \(flag.type()) to \(invitee.name())...")
                Utils.notifyObservers("FlagSending", properties: ["flag": flag, "to": invitee.name()])
                invite(invitee, flag: flag)
            }
        }
    }
    
    func invite(_ invitee: Invitee, flag: Flag) {
        Utils.notifyObservers("Inviting", properties: ["name": invitee.name(), "flag": flag])
        uploadPhotos(invitee, flag: flag,
            onComplete: {
                self.uploadFlagDetails(invitee.name(), flag: flag,
                    onComplete: {
                        invitee.inviteSuccess()
                        Utils.notifyObservers("FlagSendSuccess", properties: ["flag": flag, "to": invitee.name()])
                   },
                    onError: {
                        invitee.inviteFailure()
                        Utils.notifyObservers("FlagSendFailed", properties: ["flag": flag, "to": invitee.name()])
                    }
                )
            },
            onError: {
                invitee.inviteFailure()
                Utils.notifyObservers("FlagSendFailed", properties: ["flag": flag, "to": invitee.name()])
            })
    }
    
    fileprivate func uploadPhotos(_ invitee: Invitee, flag: Flag, onComplete: @escaping () -> Void, onError: @escaping () -> Void) {
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
                        leftToUpload = leftToUpload - 1
                        print("    Uploaded photo '\(photo.imagePath)'.  \(leftToUpload) left")
                        self.postPhotoUpload(leftToUpload, failedToUpload: failedToUpload, onComplete: onComplete, onError: onError)
                    },
                    onError: {
                        leftToUpload = leftToUpload - 1
                        failedToUpload = failedToUpload + 1
                        print("    Failed uploading photo '\(photo.imagePath)'.  \(leftToUpload) left")
                        self.postPhotoUpload(leftToUpload, failedToUpload: failedToUpload, onComplete: onComplete, onError: onError)
                    })
            }
        } else {
            onComplete()
        }
    }
    
    fileprivate func postPhotoUpload(_ leftToUpload: Int, failedToUpload: Int, onComplete: () -> Void, onError: () -> Void) {
        if leftToUpload == 0 {
            if failedToUpload == 0 {
                onComplete()
            } else {
                onError()
            }
        }
    }
    
    fileprivate func uploadImage(_ imagePath: String?, key: String, onComplete: @escaping () -> (), onError: @escaping () -> ()) {
        let uploadRequest : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = BUCKET
        uploadRequest.key = key
        uploadRequest.body = URL(fileURLWithPath: imagePath!)
        uploadRequest.acl = AWSS3ObjectCannedACL.authenticatedRead
        
        let task = transferManager.upload(uploadRequest)
        task!.continue({ (task) -> AnyObject? in
            Utils.runOnUiThread {
                if task!.error != nil {
                    print("    Image upload FAILED! \(key)")
                    onError()
                } else {
                    print("    Image uploaded \(key)")
                    onComplete()
                }
            }
            
            return nil
        })
    }
    
    fileprivate func uploadFlagDetails(_ to: String, flag: Flag, onComplete: @escaping () -> (), onError: @escaping () -> ()) {
        print("FIREBASE OP: Uploading flag " + flag.encode())
        let newNode = shareRoot(to).childByAutoId()
        newNode!.setValue(["from": Global.getUser().getName(), "memory": flag.encode()], withCompletionBlock: {
            (error:Error?, ref:Firebase?) in
            Utils.runOnUiThread {
                if (error != nil) {
                    print("     Flag upload FAILED! \(flag.type())")
                    onError()
                } else {
                    print("     Flag uploaded \(flag.type())")
                    onComplete()
                }
            }
        })
    }
    
    fileprivate func shareRoot(_ to: String) -> Firebase {
        return root.child(byAppendingPath: "users/" + to + "/given")
    }
}
