//
//  FirstViewController.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit

class RememberController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let addMemory = AddMemoryController()
    var camera: LLSimpleCamera!
    var snapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSnapButton()
        createCamera()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.addSubview(self.snapButton)
        camera.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        camera.stop()
    }
    
    func createCamera() {
        var screenRect = UIScreen.mainScreen().bounds
        self.camera = LLSimpleCamera(quality: CameraQualityPhoto, andPosition: CameraPositionBack)
        self.camera.attachToViewController(self, withFrame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height))
    }

    func createSnapButton() {
        self.snapButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        self.snapButton.frame = CGRectMake(0, 0, 70.0, 70.0)
        self.snapButton.clipsToBounds = true
        self.snapButton.layer.cornerRadius = 35.0
        self.snapButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.snapButton.layer.borderWidth = 2.0
        self.snapButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        self.snapButton.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.snapButton.layer.shouldRasterize = true
        self.snapButton.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.snapButton.center = CGPoint(x: self.view.center.x, y: self.view.bounds.height - 100)        
    }
    
    func takePhoto(sender : UIButton!) {
        let controller = self
        self.camera.capture({ (camera: LLSimpleCamera?, image: UIImage?, dict: [NSObject : AnyObject]?, err: NSError?) -> Void in
            
            self.addMemory.add(self, image: image!)
            self.snapButton.removeFromSuperview()
        }, exactSeenImage: true)
    }
}

