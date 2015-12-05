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
    
    init() {
        read()
    }
    
    func flags() -> [Flag] {
        return _flags
    }
    
    func add(flag: Flag) {
        _flags.append(flag)
    }
    
    func remove(flag: Flag) {
        _flags.removeObject(flag)
    }
    
    func events() -> [Flag] {
        let all = _flags.filter {$0.when() != nil }
        return all.sort{$0.daysToGo() < $1.daysToGo()}
    }
    
    func new() -> [Flag] {
        return _flags.filter {$0.state() == FlagState.UpdateOffered}
    }
    
    func imminentEvents() -> [Flag] {
        let imminent = _flags.filter({$0.when() != nil && $0.daysToGo() < 6 && $0.daysToGo() >= 0})
        return imminent.sort{$0.daysToGo() < $1.daysToGo()}
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
        _flags = encodedFlags.map {encodedFlag in Flag.decode(encodedFlag)}
    }
}