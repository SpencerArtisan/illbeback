//
//  PhotoAlbum.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

public class PhotoAlbum {

    var folder: String
    let fileManager = NSFileManager.defaultManager()
    
    public init() {
        folder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
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
    
    public func getMemoryImageUrls(memoryId: String) -> [NSURL] {
        let imagePaths = getImagePaths(memoryId)
        return imagePaths.map {NSURL(fileURLWithPath: $0)}
    }
    
    public func saveMemoryImage(image: UIImage?, flagId: String) {
        let imagePath = getNewImagePath(flagId)
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    }
    
    public func photos(flag: Flag) -> [Photo] {
        let flagId = flag.id()
        var photos:[Photo] = []
        let marker = flag.state() == .UpdateOffered ? ".recent" : ""
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
    
    public func addFlagImage(image: UIImage?, flagId: String) {
        let imagePath = getNewImagePath(flagId)
        print("Saving image \(imagePath)")
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
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
    
    public func delete(flag: Flag) {
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