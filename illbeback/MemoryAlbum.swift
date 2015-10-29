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
    private var memories: [Memory] = []
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
    
    func addToMap() {
        for memory in memories {
            addPin(memory)
        }
    }
    
    func contains(memory: Memory) -> Bool {
        return memories.filter({$0.id == memory.id}).count > 0
    }

    func downloadNewShares(user: User, onStart: (memory: Memory) -> Void, onComplete: (memory: Memory) -> Void) {
        print("Checking for new shared memories")
        if (user.hasName()) {
            sharer().retrieveShares(user.getName(),
                onStart: {sender, memory in
                    print("Receiving shared memory from " + sender + ": " + memory.asString())
                    onStart(memory: memory)
                },
                onComplete: {sender, memory in
                    print("Received shared memory from " + sender + ": " + memory.asString())
                    
                    
                    self.add(memory)
                    onComplete(memory: memory)
                })
        }
    }
    
    func getImminentEvents() -> [Memory] {
        return memories.filter {$0.when != nil && $0.daysToGo() < 6}
    }
    
    func addPin(memory: Memory) {
        dispatch_async(dispatch_get_main_queue(), {
            let pin = memory.asMapPin()
            self.map.addAnnotation(pin)
        })
    }
    
    func add(memory: Memory) {
        memories.append(memory)
        save()
        addPin(memory)
    }
    
    func delete(pin: MapPinView) {
        delete(pin.memory!)
        map.removeAnnotation(pin.annotation!)
    }
    
    func delete(memory: Memory) {
        let memoryIndex = find(memory)
        if (memoryIndex != nil) {
            memories.removeAtIndex(memoryIndex!)
            save()
        }
    }
    
    func share(pin: MapPinView, from: String, to: String, onComplete: () -> Void, onError: () -> Void) {
        let memoryIndex = find(pin.memory!)
        if (memoryIndex != nil) {
            let memory = memories[memoryIndex!]
            print("Sharing \(memory.type)")
            self.map.deselectAnnotation(pin.annotation, animated: false)
            sharer().share(from, to: to, memory: memory, onComplete: onComplete, onError: onError)
        } else {
            print("WARN: Failed to share unknown memory")
        }
    }

    private func find(victim: Memory) -> Int? {
        for i in 0...memories.count - 1 {
            let memory = memories[i]
            if (memory.asString() == victim.asString()) {
                return i
            }
        }
        return nil
    }
    
    func save() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let path = paths.stringByAppendingPathComponent("memories.plist")
        let memoryStrings = memories.map {memory in memory.asString()}
        props?.setValue(memoryStrings, forKey: "Memories")
        props?.writeToFile(path, atomically: true)
    }

    func read() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
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
        
        var memoryStrings = (props?.valueForKey("Memories") ?? []) as! [String]
        memories = memoryStrings.map {memoryString in Memory(memoryString: memoryString)}
    }
}