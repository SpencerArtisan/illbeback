//
//  Global.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Global {
    fileprivate static var user = Preferences.user()
    fileprivate static var deviceToken: Data?
    fileprivate static var tokenStored = false
    
    static func getUser() -> User {
        return user
    }
    
    static func setDevice(_ deviceToken: Data) {
        self.deviceToken = deviceToken
        if userDefined() {
            storeDeviceToken(true, userName: user.getName(), onSuccess: {}, onFailure: {})
        }
    }
    
    static func userDefined() -> Bool {
        return user.hasName()
    }
    
    static func setUserName(_ name: String, allowOverwrite: Bool) {
        user.setName(name)
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
    
    static func storeDeviceToken(_ allowOverwrite: Bool, userName: String?, onSuccess: @escaping () -> (), onFailure: @escaping () -> ()) {
        if !tokenStored && deviceToken != nil && userName != nil && userName != "" {
            tokenStored = true
          
            let tokenString = getDeviceTokenString()
            
            let url = "https://illbeback.firebaseio.com/users/\(userName!)/device"
            let node = Firebase(url: url)
            
            node?.observeSingleEvent(of: .value, with: { snapshot in
                if !(snapshot?.exists())! || snapshot?.value == nil {
                    print("FIREBASE OP: Uploading new device token \(tokenString) to \(url)")
                    node?.setValue(tokenString)
                    onSuccess()
                } else {
                    let existingToken = snapshot?.value
                    print("FIREBASE OP: Existing device token \(existingToken!) at \(url)")
                    if existingToken! as! String != tokenString {
                        print("FIREBASE OP: Device token MISMATCH!")
                        if allowOverwrite {
                            print("FIREBASE OP: Overwriting old device token")
                            node?.setValue(tokenString)
                            onSuccess()
                        } else {
                            print("FIREBASE OP: Disallowing overwrite of old device token")
                            onFailure()
                        }
                    } else {
                        print("FIREBASE OP: Device token matches")                        
                        onSuccess()
                    }
                }                
            })
        }
    }
    
    fileprivate static func getDeviceTokenString() -> String {
        let count = deviceToken!.count / MemoryLayout<UInt8>.size
        
        // create an array of Uint8
        var array = [UInt8](repeating: 0, count: count)
        
        // copy bytes into array
        (deviceToken! as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        var tokenString = ""
        
        for i in 0 ..< count {
            tokenString += String(format: "%02.2hhx", arguments: [array[i]])
        }
        
        return tokenString
    }
}
