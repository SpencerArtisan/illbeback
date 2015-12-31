//
//  Preferences.swift
//  illbeback
//
//  Created by Spencer Ward on 21/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Preferences {
    private static var props: NSDictionary?
    
    static func user(user: User) {
        properties().setValue(user.getFriends(), forKey: "Friends")
        properties().setValue(user.getName(), forKey: "Name")
        write()
    }
    
    static func user() -> User {
        let friends = properties().valueForKey("Friends") as? [String]
        let name = properties().valueForKey("Name") as? String
        let user = User(name: name, friends: friends ?? [])
        return user
    }
    
    static func hintedBackups() -> Bool {
        return (properties().valueForKey("hintedBackups") as? Bool) ?? false
    }
    
    static func hintedBackups(value: Bool) {
        properties().setValue(value, forKey: "hintedBackups")
        write()
    }
    
    static func hintedPressMap() -> Bool {
        return (properties().valueForKey("hintedPressMap") as? Bool) ?? false
    }
    
    static func hintedFirstFlag() -> Bool {
        return (properties().valueForKey("hintedFirstFlag") as? Bool) ?? false
    }
    
    static func hintedPressMap(value: Bool) {
        properties().setValue(value, forKey: "hintedPressMap")
        write()
    }
    
    static func hintedFirstFlag(value: Bool) {
        properties().setValue(value, forKey: "hintedFirstFlag")
        write()
    }
    
    private static func properties() -> NSDictionary {
        if props == nil {
            let propsPath = path()
            let fileManager = NSFileManager.defaultManager()
            if (!(fileManager.fileExistsAtPath(propsPath))) {
                let bundle : NSString = NSBundle.mainBundle().pathForResource("user", ofType: "plist")!
                do {
                    try fileManager.copyItemAtPath(bundle as String, toPath: propsPath)
                } catch {
                }
            }
            
            props = NSDictionary(contentsOfFile: propsPath)?.mutableCopy() as? NSDictionary
        }
        return props!
    }
    
    private static func path() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return paths.stringByAppendingPathComponent("user.plist")
    }
    
    private static func write() {
        properties().writeToFile(path(), atomically: true)
    }
}