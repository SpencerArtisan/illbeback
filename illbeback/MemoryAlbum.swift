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

    func downloadNewShares(user: User, callback: (memory: Memory) -> Void) {
        print("Checking for new shared memories")
        if (user.hasName()) {
            sharer().retrieveShares(user.getName(), callback: {sender, memory in
                print("Retrieved shared memory from " + sender + ": " + memory.asString())
                self.add(memory)
                callback(memory: memory)
            })
        }
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
        let memoryIndex = find(pin)
        if (memoryIndex != nil) {
            memories.removeAtIndex(memoryIndex!)
            save()
        }
        map.removeAnnotation(pin.annotation!)
    }
    
    func share(pin: MapPinView, from: String, to: String) {
        var memoryIndex = find(pin)
        if (memoryIndex != nil) {
            var memory = memories[memoryIndex!]
            print("Sharing \(memory.type)")
            sharer().share(from, to: to, memory: memory)
        } else {
            print("WARN: Failed to share unknown memory")
        }
    }

    private func find(pin: MapPinView) -> Int? {
        for i in 0...memories.count - 1 {
            let memory = memories[i]
            if (memory.id == pin.memory?.id) {
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