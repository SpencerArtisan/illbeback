//
//  Camera.swift
//  illbeback
//
//  Created by Spencer Ward on 27/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import AVFoundation

class Camera : NSObject {
    var camera: LLSimpleCamera!
    var snapButton: UIButton!
    var libraryButton: UIButton!
    var parentController: UIViewController!
    var callback: ((UIImage, UIDeviceOrientation) -> Void)
    var snapPlayer: AVAudioPlayer!
    
    init(parentController: UIViewController, callback: ((UIImage, UIDeviceOrientation) -> Void)) {
        self.parentController = parentController
        self.callback = callback
        super.init()
        createCamera()
        createSnapButton()
        createLibraryButton()
        createSound()
    }
    
    func createSound() {
        let snapPath = NSBundle.mainBundle().pathForResource("shutter", ofType: "mp3")
        let snapURL = NSURL(fileURLWithPath: snapPath!)
        do {
            try snapPlayer = AVAudioPlayer(contentsOfURL: snapURL)
        } catch {
        }
        snapPlayer.prepareToPlay()
    }
    
    func start() {
        let screenRect = UIScreen.mainScreen().bounds
        self.camera.attachToViewController(parentController, withFrame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height))
        self.parentController.view.addSubview(self.snapButton)
        self.parentController.view.addSubview(self.libraryButton)
        camera.start()
    }
    
    func stop() {
        camera.removeFromParentViewController()
        camera.view.removeFromSuperview()
        camera.stop()
    }
    
    func createCamera() {
        self.camera = LLSimpleCamera(quality: CameraQualityPhoto, andPosition: CameraPositionBack)
        self.camera.fixOrientationAfterCapture = false
    }
    
    func createSnapButton() {
        self.snapButton = UIButton(type: UIButtonType.System)
        self.snapButton.frame = CGRectMake(0, 0, 80.0, 80.0)
        self.snapButton.clipsToBounds = true
        self.snapButton.layer.cornerRadius = 40.0
        self.snapButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.snapButton.layer.borderWidth = 2.0
        self.snapButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        self.snapButton.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.snapButton.layer.shouldRasterize = true
        self.snapButton.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.snapButton.center = CGPoint(x: parentController.view.center.x, y: parentController.view.bounds.height - 70)
    }

    func createLibraryButton() {
        self.libraryButton = UIButton(frame: CGRectMake(0, 0, 60, 60))
        let image = UIImage(named: "Library")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.libraryButton!.setImage(image, forState: UIControlState.Normal)
        self.libraryButton?.tintColor = UIColor.blueColor()
        self.libraryButton.clipsToBounds = true
        self.libraryButton.layer.cornerRadius = 30.0
        self.libraryButton.layer.borderColor = UIColor.blackColor().CGColor
        self.libraryButton.layer.borderWidth = 1.0
        self.libraryButton.backgroundColor = UIColor.whiteColor()
        self.libraryButton.center = CGPoint(x: parentController.view.bounds.width - 50, y: parentController.view.bounds.height - 60)
    }
    
    func takePhoto(sender : UIButton!) {
        snapPlayer.play()
        
        let blackView = NSBundle.mainBundle().loadNibNamed("Black", owner: self, options: nil)[0] as? UIView
        var screenRect = UIScreen.mainScreen().bounds
        blackView!.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)
        self.parentController.view.addSubview(blackView!)
        blackView!.layer.opacity = 0
        
        UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            blackView!.layer.opacity = 1
            }, completion: {_ in
                UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    blackView!.layer.opacity = 0
                    }, completion: {_ in
                        blackView?.removeFromSuperview()
                })
        })

        self.camera.capture({ (camera: LLSimpleCamera?, image: UIImage?, dict: [NSObject : AnyObject]?, err: NSError?, orientation: UIDeviceOrientation) -> Void in
            self.snapButton.removeFromSuperview()
            self.callback(image!, orientation)
            }, exactSeenImage: true)
    }
}