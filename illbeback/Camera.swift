//
//  Camera.swift
//  illbeback
//
//  Created by Spencer Ward on 27/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import AVFoundation

class Camera : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var camera: LLSimpleCamera!
    var backButton: UIButton!
    var snapButton: UIButton!
    var libraryButton: UIButton!
    var navigationController: UINavigationController!
    var parentController: UIViewController!
    var callback: ((UINavigationController, UIImage, UIDeviceOrientation) -> Void)
    var snapPlayer: AVAudioPlayer!
    let imagePicker = UIImagePickerController()
 
    init(navigationController: UINavigationController, callback: ((UINavigationController, UIImage, UIDeviceOrientation) -> Void)) {
        self.navigationController = navigationController
        self.parentController = navigationController.topViewController
        self.callback = callback
        super.init()
        createCamera()
        createSnapButton()
        createLibraryButton()
        createBackButton()
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
        parentController.view.addSubview(self.snapButton)
        parentController.view.addSubview(self.libraryButton)
        parentController.view.addSubview(self.backButton)
        camera.start()
    }
    
    func stop() {
        camera.removeFromParentViewController()
        camera.view.removeFromSuperview()
        camera.stop()
    }
    
    func createCamera() {
        self.camera = LLSimpleCamera(quality: CameraQualityPhoto, andPosition: CameraPositionBack)
        self.camera.fixOrientationAfterCapture = true
    }
    
    func createSnapButton() {
        self.snapButton = UIButton(type: UIButtonType.System)
        self.snapButton.frame = CGRectMake(0, 0, 90.0, 90.0)
        self.snapButton.clipsToBounds = true
        self.snapButton.layer.cornerRadius = 45.0
        self.snapButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.snapButton.layer.borderWidth = 2.0
        self.snapButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        self.snapButton.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.snapButton.layer.shouldRasterize = true
        self.snapButton.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        self.snapButton.center = CGPoint(x: parentController.view.center.x, y: parentController.view.bounds.height - 60)
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
        self.libraryButton.center = CGPoint(x: parentController.view.bounds.width - 65, y: parentController.view.bounds.height - 60)
        self.libraryButton.addTarget(self, action: "library:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func createBackButton() {
        self.backButton = UIButton(frame: CGRectMake(0, 0, 60, 60))
        let image = UIImage(named: "back")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.backButton!.setImage(image, forState: UIControlState.Normal)
        self.backButton!.tintColor = UIColor.blueColor()
        self.backButton!.clipsToBounds = true
        self.backButton!.layer.cornerRadius = 30.0
        self.backButton!.layer.borderColor = UIColor.blackColor().CGColor
        self.backButton!.layer.borderWidth = 1.0
        self.backButton!.backgroundColor = UIColor.whiteColor()
        self.backButton.center = CGPoint(x: 65, y: parentController.view.bounds.height - 60)
        self.backButton!.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func takePhoto(sender : UIButton!) {
        snapPlayer.play()
        
        let blackView = NSBundle.mainBundle().loadNibNamed("Black", owner: self, options: nil)[0] as? UIView
        let screenRect = UIScreen.mainScreen().bounds
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

        self.camera.capture({ (camera: LLSimpleCamera?, var image: UIImage?, dict: [NSObject : AnyObject]?, err: NSError?, orientation: UIDeviceOrientation) -> Void in
            self.snapButton.removeFromSuperview()
            print("PICTURE TAKEN WITH ORIENTATION \(image!.imageOrientation.rawValue) SIZE \(image!.size)")
            print("DEVICE ORIENTATION IS \(orientation.rawValue)")
            if (orientation == UIDeviceOrientation.LandscapeRight) {
                image = image?.rotateImage(image, onDegrees: 90)
            } else if (orientation == UIDeviceOrientation.LandscapeLeft) {
                image = image?.rotateImage(image, onDegrees: -90)
            }
            
            print("PICTURE CORRECTED WITH ORIENTATION \(image!.imageOrientation.rawValue) SIZE \(image!.size)")
            self.callback(self.navigationController, image!, orientation)
            }, exactSeenImage: true)
    }

    func library(sender : UIButton!) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        parentController.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func goBack(sender : UIButton!) {
        self.navigationController.popViewControllerAnimated(true)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.snapButton.removeFromSuperview()
            let zoomController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ZoomController") as! ZoomController
            let photoView: UIImageView = zoomController.view.subviews[0] as! UIImageView
            print("PICTURE CHOSEN WITH ORIENTATION \(pickedImage.imageOrientation.rawValue) SIZE \(pickedImage.size)")
            
            let correctedImage = pickedImage.fixOrientation()
            print("PICTURE CORRECTED TO ORIENTATION \(correctedImage.imageOrientation.rawValue) SIZE \(correctedImage.size)")
            
            photoView.image = pickedImage
            parentController.dismissViewControllerAnimated(false, completion: nil)
            navigationController.pushViewController(zoomController, animated: false)
            let devOrient = imageToDeviceOrientation(pickedImage)
            print("Image orientation \(pickedImage.imageOrientation.rawValue) translates to device orientation \(devOrient.rawValue)")
            self.callback(navigationController, correctedImage, devOrient)
        }
    }
    
    func toDeviceOrientation(image: UIImage) -> UIDeviceOrientation {
        if (image.size.width > image.size.height) { return UIDeviceOrientation.LandscapeRight }
        return UIDeviceOrientation.FaceUp
    }
    
    func toImageOrientation(image: UIImage) -> UIImageOrientation {
        if (image.size.width > image.size.height) { return UIImageOrientation.Left }
        return UIImageOrientation.Up
    }
    
    func imageToDeviceOrientation(image: UIImage) -> UIDeviceOrientation {
        if (image.imageOrientation == UIImageOrientation.Up) { return UIDeviceOrientation.LandscapeLeft }
        if (image.imageOrientation == UIImageOrientation.Right) { return UIDeviceOrientation.Portrait }
        if (image.imageOrientation == UIImageOrientation.Down) { return UIDeviceOrientation.LandscapeRight }
        
        return UIDeviceOrientation.FaceUp
    }

}