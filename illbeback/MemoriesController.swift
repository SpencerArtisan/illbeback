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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        readMemories()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        map.delegate = self
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

    func addMemoryHere(type: String, id: String) {
        var memoryString = "\(type):some description:\(here!.coordinate.latitude):\(here!.coordinate.longitude):\(id)"
        memories.append(memoryString)
        saveMemories()
        addPin(memoryString)
    }

    func addPin(memory: String) {
        var parts = memory.componentsSeparatedByString(":")
        let name = parts[0]
        let description = parts[1]
        let lat = parts[2]
        let long = parts[3]
        let imagePath = parts[4]
        
        var coord = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (long as NSString).doubleValue)
        var poi = MapPin(coordinate: coord, title: name, subtitle: description, imagePath: imagePath)
        
        map.addAnnotation(poi)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        // create pin annotation view
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MKPinAnnotationView!
        
        if (pinView == nil) {
            pinView = MKPinAnnotationView()
            pinView.annotation = annotation
            pinView.animatesDrop = false
            pinView.enabled = true
            pinView.canShowCallout = true
            
            let view = UIView(frame: CGRectMake(0,0,60,108))
            
            view.backgroundColor = UIColor.clearColor()
            pinView.leftCalloutAccessoryView = view
            
            let pinImage : UIImage = UIImage(named: annotation.title!)!
            pinView.image = pinImage
        }
        
        
        return pinView
    }
}

