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
        Global.setUser(self)
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
        let index = friends!.indexOf(friend)
        friends?.removeAtIndex(index!)
        write()
    }
    
    private func write() {
        let path = getPath()
        props?.setValue(friends!, forKey: "Friends")
        props?.setValue(name!, forKey: "Name")
        props?.writeToFile(path, atomically: true)
    }
    
    private func read() {
        let path = getPath()
        let fileManager = NSFileManager.defaultManager()
        if (!(fileManager.fileExistsAtPath(path))) {
            let bundle : NSString = NSBundle.mainBundle().pathForResource("user", ofType: "plist")!
            do {
                try fileManager.copyItemAtPath(bundle as String, toPath: path)
            } catch {
            }
        }
    
        props = NSDictionary(contentsOfFile: path)?.mutableCopy() as? NSDictionary
    
        friends = props?.valueForKey("Friends") as? [String]
        if props?.valueForKey("Name") != nil {
            setName(props?.valueForKey("Name") as! String)
        }
    }
    
    private func getPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return paths.stringByAppendingPathComponent("user.plist")
    }
}