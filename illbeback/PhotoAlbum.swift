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
    
    func acceptRecentShare(memory: Memory) {
        delete(memory)
        let paths = getImagePaths(memory.id)
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

    func getMainPhoto(memory: Memory) -> Photo? {
        let allphotos = photos(memory)
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
    
    public func saveMemoryImage(image: UIImage?, memoryId: String) {
        let imagePath = getNewImagePath(memoryId)
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    }
    
    public func photos(memory: Memory) -> [Photo] {
        let memoryId = memory.id
        var photos:[Photo] = []
        let marker = memory.isJustReceived() ? ".recent" : ""
        var candidate = "\(folder)/Memory\(memoryId).jpg\(marker)"
        if fileManager.fileExistsAtPath(candidate) {
            photos.append(Photo(imagePath: candidate))
        }
        
        for suffix in 2...10 {
            candidate = "\(folder)/Memory\(memoryId)-\(suffix).jpg\(marker)"
            if fileManager.fileExistsAtPath(candidate) {
                photos.append(Photo(imagePath: candidate))
            }
        }
        return photos
    }
    
    public func addMemoryImage(image: UIImage?, memoryId: String) {
        let imagePath = getNewImagePath(memoryId)
        print("Saving image \(imagePath)")
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    }
    
    private func getNewImagePath(memoryId: String) -> String {
        var candidate = "\(folder)/Memory\(memoryId).jpg"
        var suffix = 2;
        while (fileManager.fileExistsAtPath(candidate)) {
            candidate = "\(folder)/Memory\(memoryId)-\(suffix).jpg"
            suffix++
        }
        return candidate
    }

    private func getImagePaths(memoryId: String) -> [String] {
        var paths:[String] = []
        var candidate = "\(folder)/Memory\(memoryId).jpg"
        paths.append(candidate)
        for suffix in 2...10 {
            candidate = "\(folder)/Memory\(memoryId)-\(suffix).jpg"
            paths.append(candidate)
        }
        return paths
    }
    
    public func delete(memory: Memory) {
        let imagePaths = getImagePaths(memory.id)
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