//
//  Photo.swift
//  illbeback
//
//  Created by Spencer Ward on 10/10/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import UIKit

open class Photo {
    let image: UIImage
    let imagePath: String
    let fileManager = FileManager.default
    
    init(imagePath: String) {
        self.image = UIImage(contentsOfFile: imagePath)!
        self.imagePath = imagePath
    }
    
    func deletePhoto() {
        do {
            print("Delete photo \(imagePath)")
            try self.fileManager.removeItem(atPath: imagePath)
        } catch {
        }
    }
}
