//
//  User.swift
//  illbeback
//
//  Created by Spencer Ward on 22/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

class User {
    private var name: String?
    private var friends: [String]?
    
    init() {
        read()
    }
    
    func getName() -> String {
        return name!
    }
    
    func getFriends() -> [String] {
        return friends!
    }
    
    private func read() {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent("user.plist")
        var fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(path)) {
            fileManager.removeItemAtPath(path, error:nil)
        }
        if (!(fileManager.fileExistsAtPath(path))) {
            var bundle : NSString = NSBundle.mainBundle().pathForResource("user", ofType: "plist")!
            fileManager.copyItemAtPath(bundle as String, toPath: path, error:nil)
        }
    
        var props = NSDictionary(contentsOfFile: path)?.mutableCopy() as? NSDictionary
    
        friends = props?.valueForKey("Friends") as? [String]
        name = props?.valueForKey("Name") as? String
    }
}