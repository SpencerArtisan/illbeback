//
//  MemoryAlbum.swift
//  illbeback
//
//  Created by Spencer Ward on 21/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

public class MemoryAlbum {
    private var _sharer: Sharer?
    var oldMemories = [String: Memory]()
    var newMemories = [String: Memory]()
    private var props: NSDictionary?
    private var map: MKMapView
    
    init(map: MKMapView) {
        self.map = map
        read()
    }
    
    func sharer() -> Sharer {
        if self._sharer == nil {
            self._sharer = Sharer(memoryAlbum: self)
        }
        return _sharer!
    }
    
    func allMemories() -> [Memory] {
        return [oldMemories.values, newMemories.values].flatMap {$0}
    }
    
    func allMemoriesExcludingDuplicates() -> [Memory] {
        let oldWithoutNewEquivalent: [Memory] = oldMemories.values.filter {self.newMemories[$0.id] == nil}
        let newMems: [Memory] = newMemories.values.reverse()
        return [oldWithoutNewEquivalent, newMems].flatMap {$0}
    }
    
    func addToMap() {
        for memory in allMemoriesExcludingDuplicates() {
            if memory.isPast() {
                delete(memory)
            } else {
                addPin(memory)
            }
        }
    }
    
    func contains(memory: Memory) -> Bool {
        return oldMemories[memory.id] != nil || newMemories[memory.id] != nil
    }

    func downloadNewShares(onStart: (memory: Memory) -> Void,
                           onComplete: (memory: Memory) -> Void,
                           onAckReceipt: (memory: Memory) -> Void) {
        print("Checking for new shared memories")
        if (Global.getUser().hasName()) {
            sharer().retrieveShares(Global.getUser().getName(),
                onStart: {sender, memory in
                    print("Receiving shared memory from " + sender + ": " + memory.asString())
                    onStart(memory: memory)
                },
                onComplete: {sender, memory in
                    print("Received shared memory from " + sender + ": " + memory.asString())
                    self.add(memory)
                    onComplete(memory: memory)
                },
                onAckReceipt: {sender, memory in
                    print("Receiving acknowledgement of shared memory from " + sender + ": " + memory.asString())
                    onAckReceipt(memory: memory)
                })
        }
    }
    
    func getImminentEvents() -> [Memory] {
        let imminent = allMemories().filter({$0.when != nil && $0.daysToGo() < 6 && $0.daysToGo() >= 0})
        return imminent.sort{$0.daysToGo() < $1.daysToGo()}
    }
    
    func getAllEvents() -> [Memory] {
        let all = allMemories().filter {$0.when != nil }
        return all.sort{$0.daysToGo() < $1.daysToGo()}
    }
    
    func addPin(memory: Memory) {
        dispatch_async(dispatch_get_main_queue(), {
            let pin = memory.asMapPin()
            self.map.addAnnotation(pin)
        })
    }
    
    func add(memory: Memory) {
        if memory.isJustReceived() {
            if oldMemories[memory.id] != nil {
                let oldPin = getPin(oldMemories[memory.id]!)
                if oldPin != nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.map.deselectAnnotation(oldPin, animated: false)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.map.removeAnnotation(oldPin!)
                        }
                    }
                }
            }

            if newMemories[memory.id] == nil {
                addPin(memory)
            }
            newMemories[memory.id] = memory
        } else {
            if oldMemories[memory.id] == nil {
                addPin(memory)
            }
            oldMemories[memory.id] = memory
        }
        save()
    }
    
    
    func getPin(memory: Memory) -> MapPin? {
        for pin in self.map.annotations {
            if pin is MapPin && (pin as! MapPin).memory.id == memory.id {
                return pin as? MapPin
            }
        }
        return nil
    }
    
    func delete(pin: MapPinView) {
        delete(pin.memory!)
        map.removeAnnotation(pin.annotation!)
    }
    
    func delete(memory: Memory) {
        oldMemories.removeValueForKey(memory.id)
    }
    
    func share(pin: MapPinView, from: String, to: String, onComplete: () -> Void, onError: () -> Void) {
        let memory = oldMemories[pin.memory!.id]
        
        if (memory != nil) {
            print("Sharing \(memory!.type)")
            self.map.deselectAnnotation(pin.annotation, animated: false)
            sharer().share(from, to: to, memory: memory!, onComplete: onComplete, onError: onError)
        } else {
            print("WARN: Failed to share unknown memory")
        }
    }
    
    func acceptRecentShare(memory: Memory, from: String) {
        print("Accepting share \(memory.asString())")
        sharer().uploadMemory(from, to: memory.originator, memory: memory)
    }
    
    func declineRecentShare(memory: Memory, from: String) {
        print("Declining share \(memory.asString())")
        sharer().uploadMemory(from, to: memory.originator, memory: memory)
    }
    
    func inviteeAccepted(invitee: String, memoryId: String) {
        let memory = oldMemories[memoryId]
        if memory != nil {
            memory!.inviteeAccepted(invitee)
        }
    }

    func inviteeDeclined(invitee: String, memoryId: String) {
        let memory = oldMemories[memoryId]
        memory!.inviteeDeclined(invitee)
    }
    
    func save() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = paths.stringByAppendingPathComponent("memories.plist")
        let memoryStrings = allMemories().map {memory in memory.asString()}
        props?.setValue(memoryStrings, forKey: "Memories")
        props?.writeToFile(path, atomically: true)
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
        
        props = NSDictionary(contentsOfFile: path)?.mutableCopy() as? NSDictionary
        
        let memoryStrings = (props?.valueForKey("Memories") ?? []) as! [String]
        let memoryList = memoryStrings.map {memoryString in Memory(memoryString: memoryString)}
        for memory in memoryList {
            if memory.isJustReceived() {
                newMemories[memory.id] = memory
            } else {
                oldMemories[memory.id] = memory
            }
        }
    }
}