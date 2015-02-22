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
    private var memories: [String] = []
    private var props: NSDictionary?
    private var map: MKMapView
    
    init(map: MKMapView) {
        self.map = map
        read()
    }
    
    func addToMap(map: MKMapView) {
        for memory in memories {
            addPin(memory)
        }
    }

    func downloadNewShares() {
        sharer.retrieveShares("spencer", {sender, memory in
            println("Retrieved shared memory from " + sender + ": " + memory)
            self.add(Memory(memoryString: memory))
        })
    }
    
    func addPin(memoryString: String) {
        let pin = Memory(memoryString: memoryString).asMapPin()
        map.addAnnotation(pin)
    }
    
    func add(memory: Memory) {
        let memoryString = memory.asString()
        memories.append(memoryString)
        save()
        addPin(memoryString)
//        sharer.share("madeleine", to: "spencer", memory: memoryString, imageUrl: PhotoAlbum().getMemoryImageUrl(memory.getId()))
    }
    
    func delete(pin: MapPinView) {
        for i in 0...memories.count - 1 {
            var memoryString = memories[i] as NSString
            if (memoryString.containsString(pin.memoryId!)) {
                memories.removeAtIndex(i)
                save()
                break
            }
        }
        map.removeAnnotation(pin.annotation)
    }
    
    func save() {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var path = paths.stringByAppendingPathComponent("memories.plist")
        props?.setValue(memories, forKey: "Memories")
        props?.writeToFile(path, atomically: true)
    }

    func read() {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var path = paths.stringByAppendingPathComponent("memories.plist")
        var fileManager = NSFileManager.defaultManager()
        if (!(fileManager.fileExistsAtPath(path))) {
            var bundle : NSString = NSBundle.mainBundle().pathForResource("Data", ofType: "plist")!
            fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
        }
        
        props = NSDictionary(contentsOfFile: path)?.mutableCopy() as? NSDictionary
        
        memories = props?.valueForKey("Memories") as [String]
    }
}