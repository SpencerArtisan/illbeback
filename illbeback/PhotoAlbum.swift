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
        folder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    }
    
    public func getMemoryImage(memoryId: String) -> UIImage? {
        var imagePath = getImagePath(memoryId)
        if (fileManager.fileExistsAtPath(imagePath)) {
            return UIImage(contentsOfFile: imagePath)!
        }
        return nil
    }

    public func saveMemoryImage(image: UIImage?, memoryId: String) {
        var imagePath = getImagePath(memoryId)
        var imageData: NSData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
    }
    
    private func getImagePath(memoryId: String) -> String {
        return "\(folder)/Memory\(memoryId).jpg"
    }
}