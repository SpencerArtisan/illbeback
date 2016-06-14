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
    private var _mutex = pthread_mutex_t()
    
    override init() {
        super.init()
        Utils.addObserver(self, selector: #selector(FlagRepository.onFlagChanged(_:)), event: "FlagChanged")
        Utils.addObserver(self, selector: #selector(FlagRepository.onFlagChanged(_:)), event: "InviteeChanged")
    }
    
    func onFlagChanged(note: NSNotification) {
        save()
    }
    
    func flags() -> [Flag] {
        return _flags.filter {$0.state() != .Dead}
    }
    
    func receive(from: String, to: String, flag: Flag, onNew: (newFlag: Flag) -> (), onUpdate: (updatedFlag: Flag) -> (), onAck: (ackedFlag: Flag?) -> ()) {
        do {
            var originalFlag = find(flag.id())
            
            if originalFlag == nil {
                // todo - better handing for declining deleted flags
                if !isDecline(from, flag: flag) {
                    print("Receiving new flag from \(from) to \(to)")
                    Utils.notifyObservers("FlagReceiving", properties: ["flag": flag, "from": from])
                    try flag.receivingNew(from)
                    onNew(newFlag: flag)
                    originalFlag = flag
                } else {
                    onAck(ackedFlag: nil)
                }
            } else if !isAck(from, flag: flag) {
                print("Receiving updated flag from \(from) to \(to)")
                originalFlag!.receivingUpdate(from, flag: flag)
                Utils.notifyObservers("FlagReceiving", properties: ["flag": flag, "from": from])
                onUpdate(updatedFlag: originalFlag!)
            }
            
            if originalFlag != nil {
                if isAck(from, flag: flag) {
                    let invitee = originalFlag!.findInvitee(from)
                    if invitee != nil {
                        let inviteeState = flag.findInvitee(from)!.state()
                        
                        if inviteeState == .Accepting {
                            invitee!.acceptSuccess()
                            onAck(ackedFlag: originalFlag!)
                        } else if inviteeState == .Declining {
                            invitee!.declineSuccess()
                            onAck(ackedFlag: originalFlag!)
                        }
                    } else {
                        onAck(ackedFlag: nil)
                    }
                } else {
                    let invitee = originalFlag!.findInvitee(to)
                    if invitee != nil {
                        invitee!.inviteSuccess()
                    }
                }
            }
        } catch {
            print("** Failed to receive flag: \(flag)")
        }
    }
    
    private func isAck(from: String, flag: Flag) -> Bool {
        let inviteeState = flag.findInvitee(from)?.state()
        return inviteeState != nil && (inviteeState! == .Accepting || inviteeState! == .Declining)
    }
    
    private func isDecline(from: String, flag: Flag) -> Bool {
        let inviteeState = flag.findInvitee(from)?.state()
        return inviteeState != nil && inviteeState! == .Declining
    }
    
    func add(flag: Flag) {
        if (find(flag.id()) != nil) {
            print("Duplicate flag added to repo: \(flag.encode())")
            _flags.removeObject(flag)
        } else {
            print("Adding flag to repo: \(flag.encode())")
        }
        
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
    
    func removeAll() {
        flags().forEach { remove($0) }
    }
    
    func find(id: String) -> Flag? {
        return flags().filter {$0.id() == id}.first
    }
    
    func events() -> [Flag] {
        let all = flags().filter {$0.when() != nil }
        return all.sort {$0.daysToGo() < $1.daysToGo()}
    }
    
    func new() -> [Flag] {
        return flags().filter {$0.state() == FlagState.ReceivedNew || $0.state() == FlagState.ReceivedUpdate}
    }
    
    func imminentEvents() -> [Flag] {
        let imminent = flags().filter {$0.when() != nil && $0.daysToGo() < 6 && $0.daysToGo() >= 0}
        return imminent.sort {$0.daysToGo() < $1.daysToGo()}
    }
    
    func purge() {
        _flags.filter({self.isPurgable($0)}).forEach {self.remove($0)}
    }
    
    private func isPurgable(flag: Flag) -> Bool {
        return flag.isPast() || flag.state() == .Dead
    }
    
    func save() {
        slowsync(saveImpl)
    }
    
    func saveImpl() {
        purge()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("memories.plist")
        let encodedFlags = flags().map {flag in flag.encode()}
        let props: NSMutableDictionary = NSMutableDictionary()
        props.setValue(encodedFlags, forKey: "Memories")
        props.writeToFile(path, atomically: true)
        _flags = flags()
    }
    
    func read() {
        slowsync(readImpl)
    }
    
    func readImpl() {
        let path = filePath()
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
                    .forEach {flag in
                        if !self.isPurgable(flag) { self.add(flag) }
                    }
    }
    
    func filePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return path.stringByAppendingPathComponent("memories.plist")
    }
    
    internal func slowsync<R>(@noescape f: () -> R) -> R {
        pthread_mutex_lock(&_mutex)
        let r = f()
        pthread_mutex_unlock(&_mutex)
        return r
    }
}