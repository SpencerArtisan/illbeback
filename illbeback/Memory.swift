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
    static let CATEGORY_NORMAL = "F"
    static let CATEGORY_SENT = "S"
    static let CATEGORY_RECEIVED = "R"
    static let CATEGORY_ACCEPTED = "A"
    static let CATEGORY_DECLINED = "D"
    
    var type: String
    var id: String
    var description: String
    var location: CLLocationCoordinate2D
    var originator: String
    var state: String
    var orientation: UIDeviceOrientation
    var when: NSDate?
    var invitees: [Invitee]
    
    init(id: String, type: String, description: String, location: CLLocationCoordinate2D, user: User, orientation: UIDeviceOrientation?, when: NSDate?) {
        self.id = id
        self.type = type
        self.description = description
        self.location = location
        self.originator = user.getName()
        self.state = Memory.CATEGORY_NORMAL
        self.orientation = orientation ?? UIDeviceOrientation.FaceUp
        self.when = when
        self.invitees = []
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
        self.state = parts.count > 6 ? parts[6] : Memory.CATEGORY_NORMAL
        self.orientation = parts.count > 7 ? (UIDeviceOrientation(rawValue: (parts[7] as NSString).integerValue))! : UIDeviceOrientation.Portrait
        self.invitees = parts.count > 9 && parts[9] != "" ? parts[9].componentsSeparatedByString(";").map{Invitee(string: $0)} : []
        self.when = parts.count > 8 && parts[8] != "" ? formatter().dateFromString(parts[8]) : nil
    }
    
    func isJustReceived() -> Bool {
        return state == Memory.CATEGORY_RECEIVED
    }

    func accept() {
        state = Memory.CATEGORY_ACCEPTED
    }

    func decline() {
        state = Memory.CATEGORY_DECLINED
    }
    
    func resetState() {
        state = Memory.CATEGORY_NORMAL
    }
    
    func justReceived() {
        if state == Memory.CATEGORY_SENT {
            state = Memory.CATEGORY_RECEIVED
        }
    }

    func justSent(to: String) {
        if state == Memory.CATEGORY_NORMAL || state == Memory.CATEGORY_SENT {
            state = Memory.CATEGORY_SENT
            let invitee = Invitee(name: to)
            invitees = invitees.filter{$0.name != to}
            invitees.append(invitee)
        }
    }
    
    func isAccepted() -> Bool {
        return state == Memory.CATEGORY_ACCEPTED
    }

    func wasAck() -> Bool {
        return state == Memory.CATEGORY_ACCEPTED || state == Memory.CATEGORY_DECLINED
    }
    
    func getInvitees() -> [Invitee] {
        return invitees
    }
    
    func inviteeAccepted(invitee: String) {
        for i in invitees {
            if i.name == invitee {
                i.accept()
            }
        }
    }
    
    func inviteeDeclined(invitee: String) {
        for i in invitees {
            if i.name == invitee {
                i.decline()
            }
        }
    }
    
    func isEvent() -> Bool {
        return when != nil
    }
    
    func asString() -> String {
        let whenString = when != nil ? formatter().stringFromDate(when!) : ""
        let inviteesString = invitees.map{$0.asString()}.joinWithSeparator(";")
        return "\(type):\(description):\(location.latitude):\(location.longitude):\(id):\(originator):\(state):\(orientation.rawValue):\(whenString):\(inviteesString)"
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
        formatter.dateFormat = "dd MMMM yyyy"
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