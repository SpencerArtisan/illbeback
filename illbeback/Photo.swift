//
//  Photo.swift
//  illbeback
//
//  Created by Spencer Ward on 10/10/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

public class Photo {
    let image: UIImage
    let imagePath: String
    let fileManager = NSFileManager.defaultManager()
    
    init(imagePath: String) {
        self.image = UIImage(contentsOfFile: imagePath)!
        self.imagePath = imagePath
    }
    
    func deletePhoto() {
        do {
            try self.fileManager.removeItemAtPath(imagePath)
        } catch {
        }
    }
}