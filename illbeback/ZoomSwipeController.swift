//
//  ZoomSwipeController.swift
//  illbeback
//
//  Created by Spencer Ward on 06/10/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class ZoomSwipeController: UIViewController, UINavigationControllerDelegate, UIPageViewControllerDataSource {
    var pageViewController : UIPageViewController?
    var photos: [UIImage] = []
    var index: Int = 0
    var backButton: UIButton?
    var snapButton: UIButton?
    var photoButton: UIButton?
    var deleteButton: UIButton?
    var created: Bool = false
    var pinToRephoto: MapPinView?
    var memoriesController: MemoriesController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!created) {
            created = true
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.dataSource = self
        
        let startingViewController = zoomController(0)
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height + 37);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)

        createBackButton()
        createDeleteButton()
        createPhotoButton()
        view.addSubview(self.backButton!)
        view.addSubview(self.deleteButton!)
        view.addSubview(self.photoButton!)
        
        pageViewController!.didMoveToParentViewController(self)
        drawDots(0)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = (viewController as! ZoomController).index
        if (currentIndex == 0) {
            return nil
        }
        return zoomController(currentIndex-1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let currentIndex = (viewController as! ZoomController).index
        if (currentIndex == photos.count - 1) {
            return nil
        }
        return zoomController(currentIndex+1)
    }
    
    private func zoomController(newIndex: Int) -> ZoomController {
        let newView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ZoomController") as! ZoomController
        let xxx = newView.view.subviews[0] as! UIImageView
        xxx.image = photos[newIndex]
        newView.index = newIndex
        newView.owner = self
        return newView
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return photos.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return index
    }
    
    func drawDots(colourIndex: Int) {
        let left = view.frame.width / 2 - (CGFloat(photos.count-1)) * 8
        for i in 0...photos.count-1 {
            let image = UIImage(named: "dot")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            let dot = UIImageView(image: image)
            dot.frame = CGRectMake(left + 16 * CGFloat(i), 45, 10, 10)
            view.addSubview(dot)
            if (i == colourIndex) {
                dot.tintColor = UIColor.orangeColor()
            } else {
                dot.tintColor = UIColor.whiteColor()
            }
        }
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
        self.backButton!.center = CGPoint(x: 65, y: view.bounds.height - 60)
        self.backButton!.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func createPhotoButton() {
        self.photoButton = UIButton(frame: CGRectMake(0, 0, 90, 90))
        let image = UIImage(named: "camerablue")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.photoButton!.setImage(image, forState: UIControlState.Normal)
        self.photoButton!.tintColor = UIColor.blueColor()
        self.photoButton!.clipsToBounds = true
        self.photoButton!.layer.cornerRadius = 45.0
        self.photoButton!.layer.borderColor = UIColor.blackColor().CGColor
        self.photoButton!.layer.borderWidth = 1.0
        self.photoButton!.backgroundColor = UIColor.whiteColor()
        self.photoButton!.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height - 60)
        self.photoButton!.addTarget(self, action: "photo:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func createDeleteButton() {
        self.deleteButton = UIButton(frame: CGRectMake(0, 0, 60, 60))
        let image = UIImage(named: "trash")
        self.deleteButton!.setImage(image, forState: UIControlState.Normal)
        self.deleteButton!.clipsToBounds = true
        self.deleteButton!.layer.cornerRadius = 30.0
        self.deleteButton!.layer.borderColor = UIColor.blackColor().CGColor
        self.deleteButton!.layer.borderWidth = 1.0
        self.deleteButton!.backgroundColor = UIColor.whiteColor()
        self.deleteButton!.center = CGPoint(x: view.bounds.width - 65, y: view.bounds.height - 60)
        self.deleteButton!.addTarget(self, action: "deletePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    func deletePhoto(sender : UIButton!) {
        memoriesController?.photoAlbum.delete("ss")
    }

    func photo(sender : UIButton!) {
        memoriesController!.rephotoMemory(pinToRephoto!)
    }
    
    func goBack(sender : UIButton!) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}