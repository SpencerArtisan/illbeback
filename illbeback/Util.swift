//
//  Util.swift
//  illbeback
//
//  Created by Spencer Ward on 04/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Utils {
    static func today() -> Date {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        return cal.startOfDay(for: Date())
    }
    
    static func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    static func runOnUiThread(_ closure:@escaping ()->()) {
//        delay(0.5, closure: closure)
//        runOnUiThread2(closure)
        DispatchQueue.main.async(execute: closure)
    }
    
    static func runOnUiThread2(_ closure:@escaping ()->()) {
//        runOnUiThread(closure)
        OperationQueue.main.addOperation(closure)
//        delay(0.5, closure: closure)
    }
    
    static func addObserver(_ observer: NSObject, selector: Selector, event: String) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: event), object: nil)
    }
    
    static func notifyObservers(_ event: String, properties: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: nil, userInfo: properties)
    }
}
