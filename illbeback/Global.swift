//
//  Global.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Global {
    private static var user = Preferences.user()
    private static var deviceToken: NSData?
    private static var tokenStored = false
    
    static func getUser() -> User {
        return user
    }
    
    static func setDevice(deviceToken: NSData) {
        self.deviceToken = deviceToken
        if userDefined() {
            storeDeviceToken(true, userName: user.getName(), onSuccess: {}, onFailure: {})
        }
    }
    
    static func userDefined() -> Bool {
        return user.hasName()
    }
    
    static func setUserName(name: String, allowOverwrite: Bool) {
        storeDeviceToken(allowOverwrite, userName: name,
            onSuccess: {
                user.setName(name)
                Preferences.user(user)
                Utils.notifyObservers("NameAccepted", properties: ["name":user.getName()])
            }, onFailure: {
                user.setName("")
                Preferences.user(user)
                let takenName = user.getName()
                tokenStored = false
                Utils.notifyObservers("NameTaken", properties: ["name":takenName])
        })
    }
    
    static func storeDeviceToken(allowOverwrite: Bool, userName: String?, onSuccess: () -> (), onFailure: () -> ()) {
        if !tokenStored && deviceToken != nil && userName != nil && userName != "" {
            tokenStored = true
          
            let tokenString = getDeviceTokenString()
            
            let url = "https://illbeback.firebaseio.com/users/\(userName!)"
            let node = Firebase(url: url)
            
            node.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if !snapshot.exists() || snapshot.value.objectForKey("iphone") == nil {
                    print("FIREBASE OP: Uploading new device token \(tokenString) to \(url)")
                    node.setValue(["iphone": tokenString])
                    onSuccess()
                } else {
                    let existingToken = snapshot.value.objectForKey("iphone")
                    print("FIREBASE OP: Existing device token \(existingToken!) at \(url)")
                    if existingToken! as! String != tokenString {
                        print("FIREBASE OP: Device token MISMATCH!")
                        if allowOverwrite {
                            print("FIREBASE OP: Overwriting old device token")
                            node.setValue(["iphone": tokenString])
                            onSuccess()
                        } else {
                            print("FIREBASE OP: Disallowing overwrite of old device token")
                            onFailure()
                        }
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