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

    static func write(user: User) {
        let path = getPath()
        props?.setValue(user.getFriends(), forKey: "Friends")
        props?.setValue(user.getName(), forKey: "Name")
        props?.writeToFile(path, atomically: true)
    }
    
    static func readUser() -> User {
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
        
        let friends = props?.valueForKey("Friends") as? [String]
        let name = props?.valueForKey("Name") as? String
        let user = User(name: name, friends: friends ?? [])
        return user
    }
    
    private static func getPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return paths.stringByAppendingPathComponent("user.plist")
    }
}