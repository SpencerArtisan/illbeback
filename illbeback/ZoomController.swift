//
//  ZoomController.swift
//  illbeback
//
//  Created by Spencer Ward on 10/05/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

import Foundation
import MapKit

class ZoomController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var photo: UIImageView!
    
    var index: Int = 0
    var owner : ZoomSwipeController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let dev = UIDevice.currentDevice()
        dev.beginGeneratingDeviceOrientationNotifications()
        let nc = NSNotificationCenter.defaultCenter()

        //using an inline closure
        nc.addObserverForName(UIDeviceOrientationDidChangeNotification, object: dev, queue: NSOperationQueue.mainQueue(), usingBlock: {
            note in if let object: UIDevice = note.object as? UIDevice {
                let orient = object.orientation
                
                let width = self.photo!.image!.size.width
                let height = self.photo!.image!.size.height

                var transform = CGAffineTransformIdentity
                if orient == UIDeviceOrientation.LandscapeLeft {
                    transform = CGAffineTransformMakeScale(width/height, width/height)
                    transform = CGAffineTransformRotate(transform, 1.57);
                } else if orient == UIDeviceOrientation.LandscapeRight {
                    transform = CGAffineTransformMakeScale(width/height, width/height)
                    transform = CGAffineTransformRotate(transform, -1.57);
                } else if orient == UIDeviceOrientation.PortraitUpsideDown {
                    transform = CGAffineTransformRotate(transform, 3.14);
                }
                
                self.photo?.transform = transform
            }})
    }
    
    override func viewWillAppear(animated: Bool) {
        owner?.index = index
        owner?.drawDots(index)
    }
    
}