//
//  FirstViewController.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit

class RememberController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var camera: LLSimpleCamera!
    var snapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        var screenRect = UIScreen.mainScreen().bounds
        
        self.camera = LLSimpleCamera(quality: CameraQualityPhoto, andPosition: CameraPositionBack)
        self.camera.attachToViewController(self, withFrame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height))
        
        // snap button to capture image
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
        
        self.view.addSubview(self.snapButton)
        
        camera.start()
    }
    
    func takePhoto(sender : UIButton!) {
        println("Button Clicked")
        self.camera.capture({ (camera: LLSimpleCamera?, image: UIImage?, dict: [NSObject : AnyObject]?, err: NSError?) -> Void in
            println("Image captured")
            var tabBarController = self.parentViewController as UITabBarController
            var memories = tabBarController.childViewControllers[0] as MemoriesController
            memories.addMemoryHere()
            tabBarController.selectedIndex = 0
        }, exactSeenImage: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

