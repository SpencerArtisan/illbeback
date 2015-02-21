//
//  SecondViewController.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MemoriesController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    var here: CLLocation!
    var props: NSDictionary?
    var memories: [String] = []
    let photoAlbum = PhotoAlbum()
    let addMemory = AddMemoryController()
    let sharer = Sharer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readMemories()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        map.delegate = self

        var tapRecognizer = UILongPressGestureRecognizer(target: self, action: "foundTap:")
        self.map.addGestureRecognizer(tapRecognizer)
        
        downloadNewShares()
    }
    
    func downloadNewShares() {
        sharer.retrieve("spencer", {sender, memory in
            println("Retrieved shared memory from " + sender + ": " + memory)
            self.addMemoryHere(memory)
        })
    }
    
    func foundTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Began) {
            var point = recognizer.locationInView(self.map)
            var tapPoint = self.map.convertPoint(point, toCoordinateFromView: self.view)
            self.addMemory.add(self, location: tapPoint)
        }
    }

    override func viewDidAppear(animated: Bool) {
        for memory in memories {
            addPin(memory)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readMemories() {
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

    func saveMemories() {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var path = paths.stringByAppendingPathComponent("memories.plist")
        props?.setValue(memories, forKey: "Memories")
        props?.writeToFile(path, atomically: true)
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        here = locations[0] as CLLocation
    }

    func addMemoryHere(type: String, id: String, description: String, location: CLLocationCoordinate2D?) {
        var memoryString = encodeMemoryString(type, id: id, description: description, location: location)
        addMemoryHere(memoryString)

        // temp test
//        let imageUrl: NSURL? = photoAlbum.getMemoryImageUrl(id)
//        sharer.share("madeleine", to: "spencer", memory: memoryString, imageUrl: imageUrl)
    }
    
    func encodeMemoryString(type: String, id: String, description: String, location: CLLocationCoordinate2D?) -> String {
        var subtitle = "No description provided"
        if (description != "") {
            subtitle = description
        }
        var locationHere = here!.coordinate
        if (location != nil) {
            locationHere = location!
        }
        return "\(type):\(subtitle):\(locationHere.latitude):\(locationHere.longitude):\(id)"
    }
    
    func decodeMemoryString(memoryString: String) -> (type: String, id: String, description: String, location: CLLocationCoordinate2D) {
        var parts = memoryString.componentsSeparatedByString(":")
        let type = parts[0]
        let description = parts[1]
        let lat = parts[2]
        let long = parts[3]
        let id = parts[4]
        
        let location = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (long as NSString).doubleValue)
        return (type, id, description, location)
    }
    
    func addMemoryHere(memoryString: String) {
        memories.append(memoryString)
        saveMemories()
        addPin(memoryString)
    }
    
    func deleteMemory(pin: MapPinView) {
        for i in 0...memories.count - 1 {
            var memoryString = memories[i] as NSString
            if (memoryString.containsString(pin.memoryId!)) {
                memories.removeAtIndex(i)
                saveMemories()
                break
            }
        }
        map.removeAnnotation(pin.annotation)
    }

    func addPin(memoryString: String) {
        let (type, id, description, location) = decodeMemoryString(memoryString)
        var poi = MapPin(coordinate: location, title: type, subtitle: description, id: id)
        map.addAnnotation(poi)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MapPin) {
            let pinData = annotation as MapPin
            
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MapPinView!
        
            if (pinView == nil) {
                var photo = photoAlbum.getMemoryImage(pinData.id)
                pinView = MapPinView(memoriesController: self, memoryId: pinData.id, photo: photo, title: pinData.title, subtitle: pinData.subtitle)
                pinView.annotation = annotation
                pinView.enabled = true
                
            
                let pinImage : UIImage = UIImage(named: pinData.title)!
                pinView.image = pinImage
            }
        
        
            return pinView
        }
        return nil
    }

}

