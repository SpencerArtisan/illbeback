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

class ZoomController: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var index: Int = 0
    var owner : ZoomSwipeController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dev = UIDevice.current
        dev.beginGeneratingDeviceOrientationNotifications()
        let nc = NotificationCenter.default
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        
        //using an inline closure
        nc.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: dev, queue: OperationQueue.main, using: {
            note in if let object: UIDevice = note.object as? UIDevice {
                let orient = object.orientation
                self.rotate(orient)
                
           }})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        owner?.index = index
        owner?.drawDots(index)
        let orientation = UIDevice.current.orientation
        rotate(orientation)
    }
    
    func rotate(_ orient: UIDeviceOrientation) {
        let width = self.photo!.image!.size.width
        let height = self.photo!.image!.size.height
        
        var transform = CGAffineTransform.identity
        if orient == UIDeviceOrientation.landscapeLeft {
            transform = CGAffineTransform(scaleX: width/height, y: width/height)
            transform = transform.rotated(by: 3.14159/2);
        } else if orient == UIDeviceOrientation.landscapeRight {
            transform = CGAffineTransform(scaleX: width/height, y: width/height)
            transform = transform.rotated(by: -3.14159/2);
        } else if orient == UIDeviceOrientation.portraitUpsideDown {
            transform = transform.rotated(by: 3.14159);
        }
        
        self.photo?.transform = transform
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photo
    }
}
