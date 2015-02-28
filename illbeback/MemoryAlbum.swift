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
    private let sharer = Sharer()
    private var memories: [Memory] = []
    private var props: NSDictionary?
    private var map: MKMapView
    
    init(map: MKMapView) {
        self.map = map
        read()
    }
    
    func addToMap() {
        for memory in memories {
            addPin(memory)
        }
    }

    func downloadNewShares(user: User, callback: (memory: Memory) -> Void) {
        println("Checking for new shared memories")
        sharer.retrieveShares(user.getName(), {sender, memory in
            println("Retrieved shared memory from " + sender + ": " + memory.asString())
            self.add(memory)
            callback(memory: memory)
        })
    }
    
    func addPin(memory: Memory) {
        let pin = memory.asMapPin()
        map.addAnnotation(pin)
    }
    
    func add(memory: Memory) {
        memories.append(memory)
        save()
        addPin(memory)
    }
    
    func delete(pin: MapPinView) {
        var memoryIndex = find(pin)
        if (memoryIndex != nil) {
            memories.removeAtIndex(memoryIndex!)
            save()
        }
        map.removeAnnotation(pin.annotation)
    }
    
    func share(pin: MapPinView, from: String, to: String) {
        var memoryIndex = find(pin)
        if (memoryIndex != nil) {
            var memory = memories[memoryIndex!]
            sharer.share(from, to: to, memory: memory, imageUrl: PhotoAlbum().getMemoryImageUrl(memory.id))
        }
    }

    private func find(pin: MapPinView) -> Int? {
        for i in 0...memories.count - 1 {
            var memory = memories[i]
            if (memory.id == pin.memory?.id) {
                return i
            }
        }
        return nil
    }
    
    func save() {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var path = paths.stringByAppendingPathComponent("memories.plist")
        var memoryStrings = memories.map {memory in memory.asString()}
        props?.setValue(memoryStrings, forKey: "Memories")
        props?.writeToFile(path, atomically: true)
    }

    func read() {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var path = paths.stringByAppendingPathComponent("memories.plist")
        var fileManager = NSFileManager.defaultManager()
        if (!(fileManager.fileExistsAtPath(path))) {
            var bundle : NSString = NSBundle.mainBundle().pathForResource("memories", ofType: "plist")!
            fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
        }
        
        props = NSDictionary(contentsOfFile: path)?.mutableCopy() as? NSDictionary
        
        var memoryStrings = props?.valueForKey("Memories") as [String]
        memories = memoryStrings.map {memoryString in Memory(memoryString: memoryString)}
    }
}