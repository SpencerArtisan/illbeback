//
//  PhotoAlbum.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

open class PhotoAlbum : NSObject {

    var folder: String
    let fileManager = FileManager.default
    
    public override init() {
        folder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        super.init()
        Utils.addObserver(self, selector: #selector(PhotoAlbum.onFlagRemoved), event: "FlagRemoved")
   }
    
    func acceptRecentShare(_ flag: Flag) {
        delete(flag)
        let paths = getImagePaths(flag.id())
        for path in paths {
            let recentPath = "\(path).recent"
            if fileManager.fileExists(atPath: recentPath) {
                print("Promoting accepted share picture \(recentPath)")
                do {
                    try fileManager.moveItem(atPath: recentPath, toPath: path)
                } catch {
                    print("Failed to promote picture \(recentPath)")
                }
            }
        }
    }

    func getMainPhoto(_ flag: Flag) -> Photo? {
        let allphotos = photos(flag)
        if (allphotos.count == 0) {
            return nil
        } else {
            return allphotos[0]
        }
    }
    
    func getFlagImageUrls(_ memoryId: String) -> [URL] {
        let imagePaths = getImagePaths(memoryId)
        return imagePaths.map {URL(fileURLWithPath: $0)}
    }
    
    func saveFlagImage(_ image: UIImage?, flagId: String) {
        let imagePath = getNewImagePath(flagId)
        let imageData: Data = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFile(atPath: imagePath, contents: imageData, attributes: nil)
    }
    
    func photos(_ flag: Flag) -> [Photo] {
        let flagId = flag.id()
        var photos:[Photo] = []
        let marker = flag.state() == .ReceivedUpdate || flag.state() == .ReceivedNew ? ".recent" : ""
        var candidate = "\(folder)/Memory\(flagId).jpg\(marker)"
        addPhoto(photos: &photos, path: candidate)
        
        for suffix in 2...10 {
            candidate = "\(folder)/Memory\(flagId)-\(suffix).jpg\(marker)"
            addPhoto(photos: &photos, path: candidate)
        }
        return photos
    }
    
    fileprivate func addPhoto(photos: inout [Photo], path: String) {
        do {
            if fileManager.fileExists(atPath: path) {
                try photos.append(Photo(imagePath: path))
            }
        } catch {
            print("Failed to add photo \(path)")
        }
    }

    func addFlagImage(_ image: UIImage?, flag: Flag) {
        let imagePath = getNewImagePath(flag.id())
        print("Saving image \(imagePath)")
        let imageData: Data = UIImageJPEGRepresentation(image!, 0.25)!
        fileManager.createFile(atPath: imagePath, contents: imageData, attributes: nil)
        Utils.notifyObservers("FlagChanged", properties: ["flag": flag])
    }
    
    fileprivate func getNewImagePath(_ flagId: String) -> String {
        var candidate = "\(folder)/Memory\(flagId).jpg"
        var suffix = 2;
        while (fileManager.fileExists(atPath: candidate)) {
            candidate = "\(folder)/Memory\(flagId)-\(suffix).jpg"
            suffix += 1
        }
        return candidate
    }

    fileprivate func getImagePaths(_ flagId: String) -> [String] {
        var paths:[String] = []
        var candidate = "\(folder)/Memory\(flagId).jpg"
        paths.append(candidate)
        for suffix in 2...10 {
            candidate = "\(folder)/Memory\(flagId)-\(suffix).jpg"
            paths.append(candidate)
        }
        return paths
    }
    
    fileprivate func getImageFilenames(_ flagId: String) -> [String] {
        var paths:[String] = []
        var candidate = "Memory\(flagId).jpg"
        paths.append(candidate)
        for suffix in 2...10 {
            candidate = "Memory\(flagId)-\(suffix).jpg"
            paths.append(candidate)
        }
        return paths
    }
    
    func allImageFiles() -> [String] {
        let files = try! fileManager.contentsOfDirectory(atPath: folder)
            .filter({$0.hasPrefix("Memory")})
            .map({"\(folder)/\($0)"})
            .filter({fileManager.fileExists(atPath: $0)})
        return files
    }
    
    func onFlagRemoved(_ note: Notification) {
        let flag = note.userInfo!["flag"] as! Flag
        delete(flag)
    }
    
    func delete(_ flag: Flag) {
        let imagePaths = getImagePaths(flag.id())
        for path in imagePaths {
            if fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.removeItem(atPath: path)
                    print("Deleted image \(path)")
                } catch {
                    print("Failed to delete image \(path)")
                }
            }
        }
    }
    
    func purge(_ flagRepository: FlagRepository) {
        let flagIds = flagRepository.flags().map { $0.id() }
        allImageFiles().forEach { imageFile in
            var purge = true
            flagIds.forEach { flagId in
                if imageFile.contains(flagId) {
                    purge = false
                }
            }
            if purge {
                print("Purging old image \(imageFile)")
                try! fileManager.removeItem(atPath: imageFile)
            }
        }
    }
}
