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
    @IBOutlet weak var tranformView: UIView!
    
    var image: UIImage?
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
        nc.addObserver(forName: UIDevice.orientationDidChangeNotification, object: dev, queue: OperationQueue.main, using: {
            note in if let object: UIDevice = note.object as? UIDevice {
                let orient = object.orientation
                self.rotate(orient)
           }})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        photo.image = image
        owner?.index = index
        owner?.drawDots(index)
        Utils.runOnUiThread {
            let orientation = UIDevice.current.orientation
            self.rotate(orientation)
        }
    }
    
    func rotate(_ orient: UIDeviceOrientation) {
        let width = self.photo!.image!.size.width
        let height = self.photo!.image!.size.height
      
        var transform = CGAffineTransform.identity
        if orient == UIDeviceOrientation.landscapeLeft {
            transform = CGAffineTransform(scaleX: width/height, y: width/height)
            transform = stretchWidthIfAlmostFullScreen(transform).rotated(by: 3.14159/2);
        } else if orient == UIDeviceOrientation.landscapeRight {
            transform = CGAffineTransform(scaleX: width/height, y: width/height)
            transform = stretchWidthIfAlmostFullScreen(transform).rotated(by: -3.14159/2);
        } else if orient == UIDeviceOrientation.portraitUpsideDown {
            transform = stretchHeightIfAlmostFullScreen(transform).rotated(by: 3.14159)
        } else if orient == UIDeviceOrientation.portrait {
            transform = stretchHeightIfAlmostFullScreen(transform)
        }
        
        self.photo?.transform = transform
    }
    
    func stretchHeightIfAlmostFullScreen(_ transform: CGAffineTransform) -> CGAffineTransform {
        let width = self.photo!.image!.size.width
        let height = self.photo!.image!.size.height
        let h = self.photo.bounds.height
        let w = self.photo.bounds.width
        let heightAdjust = (width/height) / (w/h)

        if abs(heightAdjust - 1.0) < 0.3 {
            return transform.scaledBy(x: 1, y: heightAdjust)
        }
        return transform
    }
    
    func stretchWidthIfAlmostFullScreen(_ transform: CGAffineTransform) -> CGAffineTransform {
        let width = self.photo!.image!.size.width
        let height = self.photo!.image!.size.height
        let h = self.photo.bounds.height
        let w = self.photo.bounds.width
        let heightAdjust =  (h/w) / (width/height)
        
        if abs(heightAdjust - 1.0) < 0.3 {
            return transform.scaledBy(x: heightAdjust, y: heightAdjust)
        }
        return transform
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return tranformView
    }
}
