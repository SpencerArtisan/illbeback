//
//  User.swift
//  illbeback
//
//  Created by Spencer Ward on 22/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

class User {
    private var props: NSDictionary?
    private var name: String?
    private var friends: [String]?
    
    init() {
        read()
    }
    
    func getName() -> String {
        return name!
    }
    
    func setName(name: String) {
        self.name = name
        write()
    }
    
    func hasName() -> Bool {
        return name != nil
    }
    
    func getFriends() -> [String] {
        return friends!
    }
    
    func addFriend(friend: String) {
        friends?.append(friend)
        write()
    }
    
    func removeFriend(friend: String) {
        var index = find(friends!, friend)
        friends?.removeAtIndex(index!)
        write()
    }
    
    private func write() {
        var path = getPath()
        props?.setValue(friends!, forKey: "Friends")
        props?.setValue(name!, forKey: "Name")
        props?.writeToFile(path, atomically: true)
    }
    
    private func read() {
        var path = getPath()
        var fileManager = NSFileManager.defaultManager()
        if (!(fileManager.fileExistsAtPath(path))) {
            var bundle : NSString = NSBundle.mainBundle().pathForResource("user", ofType: "plist")!
            fileManager.copyItemAtPath(bundle as String, toPath: path, error:nil)
        }
    
        props = NSDictionary(contentsOfFile: path)?.mutableCopy() as? NSDictionary
    
        friends = props?.valueForKey("Friends") as? [String]
        name = props?.valueForKey("Name") as? String
    }
    
    private func getPath() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        return paths.stringByAppendingPathComponent("user.plist")
    }
}