//
//  Memory.swift
//  illbeback
//
//  Created by Spencer Ward on 21/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import CoreLocation

public class Memory {
    let CATEGORY_NORMAL = "F"
    let CATEGORY_AWAITING_ACCEPT = "T"
    
    var type: String
    var id: String
    var description: String
    var location: CLLocationCoordinate2D
    var originator: String
    private var state: String
    var orientation: UIDeviceOrientation
    var when: NSDate?
    
    init(id: String, type: String, description: String, location: CLLocationCoordinate2D, user: User, orientation: UIDeviceOrientation?, when: NSDate?) {
        self.id = id
        self.type = type
        self.description = description
        self.location = location
        self.originator = user.getName()
        self.state = CATEGORY_NORMAL
        self.orientation = orientation ?? UIDeviceOrientation.FaceUp
        self.when = when
    }
    
    init(memoryString: String) {
        var parts = memoryString.componentsSeparatedByString(":")
        self.id = parts[4]
        self.type = parts[0]
        self.description = parts[1]
        let lat = parts[2]
        let long = parts[3]
        self.location = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (long as NSString).doubleValue)
        self.originator = parts[5]
        self.state = parts.count > 6 ? parts[6] : CATEGORY_NORMAL
        self.orientation = parts.count > 7 ? (UIDeviceOrientation(rawValue: (parts[7] as NSString).integerValue))! : UIDeviceOrientation.Portrait
        self.when = parts.count > 8 ? formatter().dateFromString(parts[8]) : nil
    }
    
    func isRecentShare() -> Bool {
        return state == CATEGORY_AWAITING_ACCEPT
    }

    func setRecentShare(recent: Bool) {
        state = recent ? CATEGORY_AWAITING_ACCEPT : CATEGORY_NORMAL
    }
    
    func asString() -> String {
        var str = "\(type):\(description):\(location.latitude):\(location.longitude):\(id):\(originator):\(state):\(orientation.rawValue)"
        if when != nil {
            str += ":\(formatter().stringFromDate(when!))"
        }
        return str
    }
    
    func whenFormatted() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        if formatter.stringFromDate(when!) == "00:00" {
            formatter.dateFormat = "EEE dd MMMM"
        } else {
            formatter.dateFormat = "EEE d MMM HH:mm"
        }
        return formatter.stringFromDate(when!)
    }
    
    func asMapPin() -> MapPin {
        return MapPin(memory: self)
    }
    
    func formatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        return formatter
    }
    
    func daysToGo() -> Int {
        let fromNow = when!.timeIntervalSinceDate(today())
        return Int(fromNow) / (60*60*24)
    }
    
    func isPast() -> Bool {
        return when != nil && when!.timeIntervalSinceDate(today()) < 0
    }
    
    func today() -> NSDate {
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        return cal.startOfDayForDate(NSDate())
    }
    
    func summary() -> String {
        if description == "" {
            return type
        } else {
            let withoutReturns = description.stringByReplacingOccurrencesOfString("\r\n", withString: " ")
            return (withoutReturns as NSString).substringToIndex(min(withoutReturns.characters.count, 30))
        }
    }
}

extension String {
    func words() -> [String] {
        
        let range = Range<String.Index>(start: self.startIndex, end: self.endIndex)
        var words = [String]()
        
        self.enumerateSubstringsInRange(range, options: NSStringEnumerationOptions.ByWords) { (substring, _, _, _) -> () in
            words.append(substring!)
        }
        
        return words
    }
}