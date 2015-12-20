//
//  PhotoAlbum.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

public class PhotoAlbum : NSObject {

    var folder: String
    let fileManager = NSFileManager.defaultManager()
    
    public override init() {
        folder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        super.init()
        Utils.addObserver(self, selector: "onFlagRemoved:", event: "FlagRemoved")
   }
    
    func acceptRecentShare(flag: Flag) {
        delete(flag)
        let paths = getImagePaths(flag.id())
        for path in paths {
            let recentPath = "\(path).recent"
            if fileManager.fileExistsAtPath(recentPath) {
                print("Promoting accepted share picture \(recentPath)")
                do {
                    try fileManager.moveItemAtPath(recentPath, toPath: path)
                } catch {
                    print("Failed to promote picture \(recentPath)")
                }
            }
        }
    }

    func getMainPhoto(flag: Flag) -> Photo? {
        let allphotos = photos(flag)
        if (allphotos.count == 0) {
            return nil
        } else {
            return allphotos[0]
        }
    }
    
    func getFlagImageUrls(memoryId: String) -> [NSURL] {
        let imagePaths = getImagePaths(memoryId)
        return imagePaths.map {NSURL(fileURLWithPath: $0)}
    }
    
    func saveFlagImage(image: UIImage?, flagId: String) {
        let imagePath = getNewImagePath(flagId)
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    }
    
    func photos(flag: Flag) -> [Photo] {
        let flagId = flag.id()
        var photos:[Photo] = []
        let marker = flag.state() == .ReceivedUpdate || flag.state() == .ReceivedNew ? ".recent" : ""
        var candidate = "\(folder)/Memory\(flagId).jpg\(marker)"
        if fileManager.fileExistsAtPath(candidate) {
            photos.append(Photo(imagePath: candidate))
        }
        
        for suffix in 2...10 {
            candidate = "\(folder)/Memory\(flagId)-\(suffix).jpg\(marker)"
            if fileManager.fileExistsAtPath(candidate) {
                photos.append(Photo(imagePath: candidate))
            }
        }
        return photos
    }
    
    func addFlagImage(image: UIImage?, flag: Flag) {
        let imagePath = getNewImagePath(flag.id())
        print("Saving image \(imagePath)")
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
        Utils.notifyObservers("FlagChanged", properties: ["flag": flag])
    }
    
    private func getNewImagePath(flagId: String) -> String {
        var candidate = "\(folder)/Memory\(flagId).jpg"
        var suffix = 2;
        while (fileManager.fileExistsAtPath(candidate)) {
            candidate = "\(folder)/Memory\(flagId)-\(suffix).jpg"
            suffix++
        }
        return candidate
    }

    private func getImagePaths(flagId: String) -> [String] {
        var paths:[String] = []
        var candidate = "\(folder)/Memory\(flagId).jpg"
        paths.append(candidate)
        for suffix in 2...10 {
            candidate = "\(folder)/Memory\(flagId)-\(suffix).jpg"
            paths.append(candidate)
        }
        return paths
    }
    
    func allImageFiles() -> [String] {
        let files = try! fileManager.contentsOfDirectoryAtPath(folder)
            .filter({$0.hasPrefix("Memory")})
            .map({"\(folder)/\($0)"})
            .filter({fileManager.fileExistsAtPath($0)})
        return Array(files[0...1])
    }
    
    func onFlagRemoved(note: NSNotification) {
        let flag = note.userInfo!["flag"] as! Flag
        delete(flag)
    }
    
    func delete(flag: Flag) {
        let imagePaths = getImagePaths(flag.id())
        for path in imagePaths {
            if fileManager.fileExistsAtPath(path) {
                do {
                    try fileManager.removeItemAtPath(path)
                    print("Deleted image \(path)")
                } catch {
                    print("Failed to delete image \(path)")
                }
            }
        }
    }
}