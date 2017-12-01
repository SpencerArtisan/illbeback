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
    var snapPlayer: AVAudioPlayer?
    let imagePicker = UIImagePickerController()
 
    init(navigationController: UINavigationController, callback: @escaping ((UINavigationController, UIImage, UIDeviceOrientation) -> Void)) {
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
        let snapPath = Bundle.main.path(forResource: "shutter", ofType: "mp3")
        let snapURL = URL(fileURLWithPath: snapPath!)
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            print("SIMULATOR")
        #else
            do {
                try snapPlayer = AVAudioPlayer(contentsOf: snapURL)
                snapPlayer!.prepareToPlay()
            } catch {
            }
        #endif
    }
    
    func start() {
        blackout()
        let screenRect = UIScreen.main.bounds
        self.camera.attach(to: parentController, withFrame: CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height))
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
        self.snapButton = UIButton(type: UIButtonType.system)
        self.snapButton.frame = CGRect(x: 0, y: 0, width: 90.0, height: 90.0)
        self.snapButton.clipsToBounds = true
        self.snapButton.layer.cornerRadius = 45.0
        self.snapButton.layer.borderColor = UIColor.white.cgColor
        self.snapButton.layer.borderWidth = 2.0
        self.snapButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.snapButton.layer.rasterizationScale = UIScreen.main.scale
        self.snapButton.layer.shouldRasterize = true
        self.snapButton.addTarget(self, action: #selector(Camera.takePhoto(_:)), for: UIControlEvents.touchUpInside)
        self.snapButton.center = CGPoint(x: parentController.view.center.x, y: parentController.view.bounds.height - 66)
    }

    func createLibraryButton() {
        self.libraryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let image = UIImage(named: "Library")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.libraryButton!.setImage(image, for: UIControlState())
        self.libraryButton?.tintColor = UIColor.blue
        self.libraryButton.clipsToBounds = true
        self.libraryButton.layer.cornerRadius = 30.0
        self.libraryButton.layer.borderColor = UIColor.black.cgColor
        self.libraryButton.layer.borderWidth = 1.0
        self.libraryButton.backgroundColor = UIColor.white
        self.libraryButton.center = CGPoint(x: parentController.view.bounds.width - 65, y: parentController.view.bounds.height - 66)
        self.libraryButton.addTarget(self, action: #selector(Camera.library(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func createBackButton() {
        self.backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let image = UIImage(named: "back")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.backButton!.setImage(image, for: UIControlState())
        self.backButton!.tintColor = UIColor.blue
        self.backButton!.clipsToBounds = true
        self.backButton!.layer.cornerRadius = 30.0
        self.backButton!.layer.borderColor = UIColor.black.cgColor
        self.backButton!.layer.borderWidth = 1.0
        self.backButton!.backgroundColor = UIColor.white
        self.backButton.center = CGPoint(x: 65, y: parentController.view.bounds.height - 66)
        self.backButton!.addTarget(self, action: #selector(Camera.goBack(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func takePhoto(_ sender : UIButton!) {
        snapPlayer?.play()
        let blackView = blackout()
        
        UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            blackView.layer.opacity = 1
            }, completion: {_ in
                UIView.animate(withDuration: 0.15, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    blackView.layer.opacity = 0
                    }, completion: {_ in
                        blackView.removeFromSuperview()
                })
        })

        self.camera.capture({ (camera: LLSimpleCamera?, image: UIImage?, dict: [AnyHashable: Any]?, err: Error?, orientation: UIDeviceOrientation) -> Void in
            self.snapButton.removeFromSuperview()
            var modifiedImage = image
            if (orientation == UIDeviceOrientation.landscapeRight) {
                modifiedImage = image?.rotateImage(image, onDegrees: 90)
            } else if (orientation == UIDeviceOrientation.landscapeLeft) {
                modifiedImage = image?.rotateImage(image, onDegrees: -90)
            }
            
            self.callback(self.navigationController, modifiedImage!, orientation)
            }, exactSeenImage: true)
    }
    
    func blackout() -> UIView {
        let blackView = Bundle.main.loadNibNamed("Black", owner: self, options: nil)?[0] as? UIView
        let screenRect = UIScreen.main.bounds
        blackView!.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        self.parentController.view.addSubview(blackView!)
        blackView!.layer.opacity = 0
        return blackView!
    }

    func library(_ sender : UIButton!) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        parentController.present(imagePicker, animated: false, completion: nil)
    }
    
    func goBack(_ sender : UIButton!) {
        self.navigationController.popViewController(animated: false)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.snapButton.removeFromSuperview()
            parentController.dismiss(animated: false, completion: nil)

            print(navigationController.viewControllers.count)
            if navigationController.viewControllers.count == 2 {
                let zoomController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZoomController") as! ZoomController
                zoomController.image = pickedImage
                navigationController.pushViewController(zoomController, animated: false)
            }
            
            let devOrient = imageToDeviceOrientation(pickedImage)
            let correctedImage = pickedImage.fixOrientation()
            self.callback(navigationController, correctedImage!, devOrient)
        }
    }
    
    func toDeviceOrientation(_ image: UIImage) -> UIDeviceOrientation {
        if (image.size.width > image.size.height) { return UIDeviceOrientation.landscapeRight }
        return UIDeviceOrientation.faceUp
    }
    
    func toImageOrientation(_ image: UIImage) -> UIImageOrientation {
        if (image.size.width > image.size.height) { return UIImageOrientation.left }
        return UIImageOrientation.up
    }
    
    func imageToDeviceOrientation(_ image: UIImage) -> UIDeviceOrientation {
        if (image.imageOrientation == UIImageOrientation.up) { return UIDeviceOrientation.landscapeLeft }
        if (image.imageOrientation == UIImageOrientation.right) { return UIDeviceOrientation.portrait }
        if (image.imageOrientation == UIImageOrientation.down) { return UIDeviceOrientation.landscapeRight }
        
        return UIDeviceOrientation.faceUp
    }

}
