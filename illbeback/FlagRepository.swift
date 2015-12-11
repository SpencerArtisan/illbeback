//
//  FlagRepository.swift
//  illbeback
//
//  Created by Spencer Ward on 04/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class FlagRepository : NSObject {
    private var _flags = [Flag]()
    private var _reading = false
    
    override init() {
        super.init()
        Utils.addObserver(self, selector: "onFlagChanged:", event: "FlagChanged")
        Utils.addObserver(self, selector: "onFlagChanged:", event: "InviteeChanged")
    }
    
    func onFlagChanged(note: NSNotification) {
        save()
    }
    
    func flags() -> [Flag] {
        return _flags.filter {$0.state() != .Dead}
    }
    
    func receive(from: String, flag: Flag, onNew: () -> (), onUpdate: () -> (), onAck: () -> ()) {
        do {
            var originalFlag = find(flag.id())
            let flagState = flag.state()
            
            if originalFlag == nil {
                if flagState != FlagState.Accepting && flagState != FlagState.Declining {
                    flag.clearInvitees()
                }
                try flag.receivingNew(from)
                add(flag)
                onNew()
                originalFlag = flag
            } else if flagState == .Neutral {
                originalFlag!.receivingUpdate(flag)
                onUpdate()
            }
            
            let invitee = originalFlag!.findInvitee(from)
            
            if flagState == FlagState.Accepting {
                if invitee != nil {
                    invitee!.accepted()
                }
                onAck()
            } else if flagState == FlagState.Declining {
                if invitee != nil {
                    invitee!.declined()
                }
                onAck()
            }
        } catch {
            print("** Failed to receive flag: \(flag)")
        }
    }
    
    func add(flag: Flag) {
        print("Adding flag to repo: \(flag.encode())")
        _flags.append(flag)
        Utils.notifyObservers("FlagAdded", properties: ["flag": flag])
        save()
    }
    
    func remove(flag: Flag) {
        print("Removing \(flag.type()) from repo")
        _flags.removeObject(flag)
        Utils.notifyObservers("FlagRemoved", properties: ["flag": flag])
        save()
    }
    
    func find(id: String) -> Flag? {
        return _flags.filter {$0.id() == id}.first
    }
    
    func events() -> [Flag] {
        let all = flags().filter {$0.when() != nil }
        return all.sort {$0.daysToGo() < $1.daysToGo()}
    }
    
    func new() -> [Flag] {
        return flags().filter {$0.state() == FlagState.ReceivedNew || $0.state() == FlagState.ReceivedUpdate}
    }
    
    func imminentEvents() -> [Flag] {
        let imminent = _flags.filter {$0.when() != nil && $0.daysToGo() < 6 && $0.daysToGo() >= 0}
        return imminent.sort {$0.daysToGo() < $1.daysToGo()}
    }
    
    func purge() {
        _flags = _flags.filter {!$0.isPast()}
        Utils.delay(0.5) {
            self.save()
        }
    }
    
    func save() {
        if _reading {
            return
        }
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("memories.plist")
        let encodedFlags = _flags.map {flag in flag.encode()}
        let props: NSMutableDictionary = NSMutableDictionary()
        props.setValue(encodedFlags, forKey: "Memories")
        props.writeToFile(path, atomically: true)
    }
    
    func read() {
        _reading = true
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("memories.plist")
        let fileManager = NSFileManager.defaultManager()
        if (!(fileManager.fileExistsAtPath(path))) {
            let bundle : NSString = NSBundle.mainBundle().pathForResource("memories", ofType: "plist")!
            do {
                try fileManager.copyItemAtPath(bundle as String, toPath: path)
            } catch {
                print("Failed to read local flag store")
            }
        }
        
        let props = NSDictionary(contentsOfFile: path)?.mutableCopy() as! NSDictionary
        
        let encodedFlags = (props.valueForKey("Memories") ?? []) as! [String]
        encodedFlags.map {encodedFlag in Flag.decode(encodedFlag)}
                    .forEach {flag in self.add(flag)}
        _reading = false
    }
}