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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.dataSource = self
        
        let startingViewController = zoomController(0)
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
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
        //newView.photo.image = photos[newIndex]
        newView.index = newIndex
        return newView
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return photos.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return index
    }
    
}