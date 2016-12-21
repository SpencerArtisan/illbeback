//
//  Preferences.swift
//  illbeback
//
//  Created by Spencer Ward on 21/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Preferences {
    fileprivate static var props: NSDictionary?
    
    static func user(_ user: User) {
        properties().setValue(user.getFriends(), forKey: "Friends")
        properties().setValue(user.getName(), forKey: "Name")
        write()
    }
    
    static func user() -> User {
        let friends = properties().value(forKey: "Friends") as? [String]
        let name = properties().value(forKey: "Name") as? String
        let user = User(name: name, friends: friends ?? [])
        return user
    }
    
    static func hintedBackups() -> Bool {
        return (properties().value(forKey: "hintedBackups") as? Bool) ?? false
    }
    
    static func hintedBackups(_ value: Bool) {
        properties().setValue(value, forKey: "hintedBackups")
        write()
    }
    
    static func hintedPressMap() -> Bool {
        return (properties().value(forKey: "hintedPressMap") as? Bool) ?? false
    }
    
    static func hintedFirstFlag() -> Bool {
        return (properties().value(forKey: "hintedFirstFlag") as? Bool) ?? false
    }
    
    static func hintedPressMap(_ value: Bool) {
        properties().setValue(value, forKey: "hintedPressMap")
        write()
    }
    
    static func hintedFirstFlag(_ value: Bool) {
        properties().setValue(value, forKey: "hintedFirstFlag")
        write()
    }
    
    fileprivate static func properties() -> NSDictionary {
        if props == nil {
            let propsPath = path()
            let fileManager = FileManager.default
            if (!(fileManager.fileExists(atPath: propsPath))) {
                let bundle : NSString = Bundle.main.path(forResource: "user", ofType: "plist")! as NSString
                do {
                    try fileManager.copyItem(atPath: bundle as String, toPath: propsPath)
                } catch {
                }
            }
            
            props = NSDictionary(contentsOfFile: propsPath)?.mutableCopy() as? NSDictionary
        }
        return props!
    }
    
    fileprivate static func path() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return paths.appendingPathComponent("user.plist")
    }
    
    fileprivate static func write() {
        properties().write(toFile: path(), atomically: true)
    }
}
