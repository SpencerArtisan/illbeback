//
//  Global.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Global {
    private static var user = User()
    private static var deviceToken: NSData?
    private static var tokenStored = false
    
    static func getUser() -> User {
        return user
    }
    
    static func setDevice(deviceToken: NSData) {
        self.deviceToken = deviceToken
        storeDeviceToken()
    }
    
    static func userDefined() -> Bool {
        return user.hasName()
    }
    
    static func setUserName(name: String) {
        user.setName(name)
        storeDeviceToken()
    }
    
    static func storeDeviceToken() {
        if !tokenStored && deviceToken != nil && userDefined() {
            tokenStored = true
          
            let tokenString = getDeviceTokenString()
            
            let url = "https://illbeback.firebaseio.com/users/\(self.user.getName())"
            let node = Firebase(url: url)
            
            node.observeSingleEventOfType(.Value, withBlock: {
                snapshot in
               
                if !snapshot.exists() || snapshot.value.objectForKey("iphone") == nil {
                    print("FIREBASE OP: NO existing device token")
                    NSNotificationCenter.defaultCenter().postNotificationName("NameAccepted", object: nil, userInfo: ["name":user.getName()])
                    print("FIREBASE OP: Uploading device token \(tokenString) to \(url)")
                    node.setValue(["iphone": tokenString])
                } else {
                    let existingToken = snapshot.value.objectForKey("iphone")
                    print("FIREBASE OP: Existing device token \(existingToken!)")
                    if existingToken! as! String != tokenString {
                        print("FIREBASE OP: Device token MISMATCH!")
                        let takenName = user.getName()
                        user.setName("")
                        tokenStored = false
                        NSNotificationCenter.defaultCenter().postNotificationName("NameTaken", object: nil, userInfo: ["name":takenName])
                        return
                    }
                }                
            })
        }
    }
    
    private static func getDeviceTokenString() -> String {
        let count = deviceToken!.length / sizeof(UInt8)
        
        // create an array of Uint8
        var array = [UInt8](count: count, repeatedValue: 0)
        
        // copy bytes into array
        deviceToken!.getBytes(&array, length:count * sizeof(UInt8))
        
        var tokenString = ""
        
        for var i = 0; i < count; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [array[i]])
        }
        
        return tokenString
    }

}