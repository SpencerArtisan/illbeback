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
    private var memories: [String] = []
    var props: NSDictionary?
    
    init() {
        read()
    }
    
    func addToMap(map: MKMapView) {
        for memory in memories {
            addPin(memory, map: map)
        }
    }

    func addPin(memoryString: String, map: MKMapView) {
        let pin = Memory(memoryString: memoryString).asMapPin()
        map.addAnnotation(pin)
    }
    
    func add(memory: Memory, map: MKMapView) {
        let memoryString = memory.asString()
        memories.append(memoryString)
        save()
        addPin(memoryString, map: map)
    }
    
    func delete(pin: MapPinView, map: MKMapView) {
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