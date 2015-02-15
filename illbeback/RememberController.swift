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
    var categoryView: UIView!
    var memoryId: String?
    let photoAlbum = PhotoAlbum()
    
    @IBAction func addCafe(sender: AnyObject) {
        addMemory("Cafe")
    }

    @IBAction func addRestaurant(sender: AnyObject) {
        addMemory("Restaurant")
    }
    
    @IBAction func addPub(sender: AnyObject) {
        addMemory("Pub")
    }
    
    @IBAction func addShop(sender: AnyObject) {
        addMemory("Shop")
    }
    
    @IBAction func addGallery(sender: AnyObject) {
        addMemory("Gallery")
    }
    
    @IBAction func addChurch(sender: AnyObject) {
        addMemory("Church")
    }
    
    @IBAction func addOther(sender: AnyObject) {
        addMemory("Other")
    }

    @IBAction func addGreenSpace(sender: AnyObject) {
        addMemory("Green Space")
    }
    
    @IBAction func addPlaceToStay(sender: AnyObject) {
        addMemory("Place to Stay")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSnapButton()
        createCamera()
        categoryView = NSBundle.mainBundle().loadNibNamed("CategoryView", owner: self, options: nil)[0] as? UIView
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.addSubview(self.snapButton)
        camera.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        camera.stop()
        self.categoryView.removeFromSuperview()
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
            self.memoryId = NSUUID().UUIDString
            self.photoAlbum.saveMemoryImage(image, memoryId: self.memoryId!)
            self.snapButton.removeFromSuperview()
            self.showCategorySelector()
        }, exactSeenImage: true)
    }
    
    func showCategorySelector() {
        self.view.addSubview(self.categoryView)
        self.categoryView?.frame.origin.x = -160
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            var sliderFrame = self.categoryView?.frame
            sliderFrame?.origin.x = 0
            self.categoryView?.frame = sliderFrame!
            }, completion: {_ in })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addMemory(image: String) {
        var tabBarController = self.parentViewController as UITabBarController
        var memories = tabBarController.childViewControllers[0] as MemoriesController
        memories.addMemoryHere(image, id: memoryId!)
        tabBarController.selectedIndex = 0
    }
}

