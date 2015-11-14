//
//  Global.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Global {
    private static var user: User?
    private static var deviceToken: NSData?
    private static var tokenStored = false
    
    static func setUser(user: User) {
        self.user = user
        storeDeviceToken()
    }
    
    static func setDevice(deviceToken: NSData) {
        self.deviceToken = deviceToken
        storeDeviceToken()
    }
    
    static func storeDeviceToken() {
        if !tokenStored && user != nil && deviceToken != nil {
            tokenStored = true

            let count = deviceToken!.length / sizeof(UInt8)
            
            // create an array of Uint8
            var array = [UInt8](count: count, repeatedValue: 0)
            
            // copy bytes into array
            deviceToken!.getBytes(&array, length:count * sizeof(UInt8))
            
            var tokenString = ""
            
            for var i = 0; i < count; i++ {
                tokenString += String(format: "%02.2hhx", arguments: [array[i]])
            }
            
            let url = "https://illbeback.firebaseio.com/users/\(self.user!.getName())"
            print("FIREBASE OP: Uploading device token \(tokenString) to \(url)")
            let node = Firebase(url: url)
            node.setValue(["iphone": tokenString])
        }
    }

}