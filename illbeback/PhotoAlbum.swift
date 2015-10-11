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
        return [NSURL(fileURLWithPath: imagePaths[0])]
    }
    
    public func saveMemoryImage(image: UIImage?, memoryId: String) {
        let imagePath = getNewImagePath(memoryId)
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    }
    
    public func photos(memory: Memory) -> [Photo] {
        let memoryId = memory.id
        var photos:[Photo] = []
        var candidate = "\(folder)/Memory\(memoryId).jpg"
        var suffix = 2
        while (fileManager.fileExistsAtPath(candidate)) {
            photos.append(Photo(imagePath: candidate))
            candidate = "\(folder)/Memory\(memoryId)-\(suffix).jpg"
            suffix++
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
        var suffix = 2;
        while (fileManager.fileExistsAtPath(candidate)) {
            candidate = "\(folder)/Memory\(memoryId)-\(suffix).jpg"
            paths.append(candidate)
            suffix++
        }
        return paths
    }
}