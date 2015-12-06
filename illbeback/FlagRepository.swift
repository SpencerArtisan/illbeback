//
//  FlagRepository.swift
//  illbeback
//
//  Created by Spencer Ward on 04/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class FlagRepository {
    private var _flags = [Flag]()
    
    func flags() -> [Flag] {
        return _flags
    }
    
    func receive(from: String, flag: Flag, onNew: () -> (), onUpdate: () -> (), onAck: () -> ()) {
        var originalFlag = find(flag.id())
        let flagState = flag.state()
        
        if originalFlag == nil {
            flag.receivingNew()
            add(flag)
            onNew()
            originalFlag = flag
        } else if flagState == .Neutral {
            originalFlag!.receivingUpdate(flag)
            onUpdate()
        }

        let invitee = originalFlag!.findInvitee(from)
        if flagState == FlagState.AcceptingNew {
            invitee!.accepted()
            onAck()
        } else if flagState == FlagState.DecliningNew {
            invitee!.declined()
            onAck()
        } else if flagState == FlagState.AcceptingUpdate {
            invitee!.accepted()
            onAck()
        } else if flagState == FlagState.DecliningUpdate {
            invitee!.declined()
            onAck()
        }
    }
    
    func add(flag: Flag) {
        _flags.append(flag)
        Utils.notifyObservers("FlagAdded", properties: ["flag": flag])
    }
    
    func remove(flag: Flag) {
        _flags.removeObject(flag)
        Utils.notifyObservers("FlagRemoved", properties: ["flag": flag])
    }
    
    func find(id: String) -> Flag? {
        return _flags.filter {$0.id() == id}.first
    }
    
    func events() -> [Flag] {
        let all = _flags.filter {$0.when() != nil }
        return all.sort {$0.daysToGo() < $1.daysToGo()}
    }
    
    func new() -> [Flag] {
        return _flags.filter {$0.state() == FlagState.ReceivedNew}
    }
    
    func imminentEvents() -> [Flag] {
        let imminent = _flags.filter {$0.when() != nil && $0.daysToGo() < 6 && $0.daysToGo() >= 0}
        return imminent.sort {$0.daysToGo() < $1.daysToGo()}
    }
    
    func save() {
//        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//        let path = paths.stringByAppendingPathComponent("memories.plist")
//        let encodedFlags = _flags.map {flag in flag.encode()}
//        let props: NSDictionary = NSDictionary()
//        props.setValue(encodedFlags, forKey: "Memories")
//        props.writeToFile(path, atomically: true)
    }
    
    func read() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("memories.plist")
        let fileManager = NSFileManager.defaultManager()
        if (!(fileManager.fileExistsAtPath(path))) {
            let bundle : NSString = NSBundle.mainBundle().pathForResource("memories", ofType: "plist")!
            do {
                try fileManager.copyItemAtPath(bundle as String, toPath: path)
            } catch {
            }
        }
        
        let props = NSDictionary(contentsOfFile: path)?.mutableCopy() as! NSDictionary
        
        let encodedFlags = (props.valueForKey("Memories") ?? []) as! [String]
        encodedFlags.map {encodedFlag in Flag.decode(encodedFlag)}
                    .forEach {flag in self.add(flag)}
    }
}