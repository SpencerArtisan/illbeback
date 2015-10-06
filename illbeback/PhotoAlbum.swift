//
//  PhotoAlbum.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

public class PhotoAlbum {
    let fileManager = NSFileManager.defaultManager()
    var folder: String
    
    public init() {
        folder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
    }

    public func delete(memoryId: String) {
        if (photoExists(memoryId)) {
            let imagePath = getImagePath(memoryId)
            print("Deleting file " + imagePath)
            do {
                try self.fileManager.removeItemAtPath(imagePath)
            } catch {
            }
        }
    }
    
    public func photoExists(memoryId: String) -> Bool {
        let imagePath = getImagePath(memoryId)
        return fileManager.fileExistsAtPath(imagePath)
    }
    
    public func getMemoryImageUrl(memoryId: String) -> NSURL {
        let imagePath = getImagePath(memoryId)
        return NSURL(fileURLWithPath: imagePath)
    }
    
    public func getMemoryImage(memoryId: String) -> UIImage? {
        if (photoExists(memoryId)) {
            let imagePath = getImagePath(memoryId)
            return UIImage(contentsOfFile: imagePath)!
        }
        return nil
    }

    public func saveMemoryImage(image: UIImage?, memoryId: String) {
        let imagePath = getImagePath(memoryId)
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    }
    
    public func photos(memory: Memory) -> [UIImage] {
        let memoryId = memory.id
        var images:[UIImage] = []
        var candidate = "\(folder)/Memory\(memoryId).jpg"
        var suffix = 2
        while (fileManager.fileExistsAtPath(candidate)) {
            images.append(UIImage(contentsOfFile: candidate)!)
            candidate = "\(folder)/Memory\(memoryId)-\(suffix).jpg"
            suffix++
        }
        return images
    }
    
    public func addMemoryImage(image: UIImage?, memoryId: String) {
        let imagePath = getNewImagePath(memoryId)
        print("Saving image \(imagePath)")
        let imageData: NSData = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    }
    
    public func getImagePath(memoryId: String) -> String {
        return "\(folder)/Memory\(memoryId).jpg"
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
}