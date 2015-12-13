//
//  Util.swift
//  illbeback
//
//  Created by Spencer Ward on 04/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Utils {
    static func today() -> NSDate {
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        return cal.startOfDayForDate(NSDate())
    }
    
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    static func runOnUiThread(closure:()->()) {
//        delay(0.5, closure: closure)
//        runOnUiThread2(closure)
        dispatch_async(dispatch_get_main_queue(), closure)
    }
    
    static func runOnUiThread2(closure:()->()) {
//        runOnUiThread(closure)
        NSOperationQueue.mainQueue().addOperationWithBlock(closure)
//        delay(0.5, closure: closure)
    }
    
    static func addObserver(observer: NSObject, selector: Selector, event: String) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: event, object: nil)
    }
    
    static func notifyObservers(event: String, properties: [NSObject: AnyObject]) {
        NSNotificationCenter.defaultCenter().postNotificationName(event, object: nil, userInfo: properties)
    }
}