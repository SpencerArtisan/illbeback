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
    var photos: [Photo] = []
    var index: Int = 0
    var backButton: UIButton?
    var snapButton: UIButton?
    var photoButton: UIButton?
    var deleteButton: UIButton?
    var created: Bool = false
    var pinToRephoto: FlagAnnotationView?
    var mapController: MapController?
    var dots: [UIImageView] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photos = mapController!.photoAlbum.photos(pinToRephoto!.flag!)

        if (!created) {
            created = true
        
            pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            pageViewController!.dataSource = self
        
            let startingViewController = zoomController(0)
            let viewControllers: NSArray = [startingViewController]
            pageViewController!.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: false, completion: nil)
            pageViewController!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height + 37);
        
            addChildViewController(pageViewController!)
            view.addSubview(pageViewController!.view)

            createBackButton()
            createDeleteButton()
            createPhotoButton()
            view.addSubview(self.backButton!)
            view.addSubview(self.deleteButton!)
            view.addSubview(self.photoButton!)
        
            pageViewController!.didMove(toParentViewController: self)
        }
        drawDots(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let previousPhotoPaths = self.photos.map { $0.imagePath }
        
        self.photos = mapController!.photoAlbum.photos(pinToRephoto!.flag!)
        if self.photos.count == 0 {
            goBack(nil)
            return
        }
        var i = 0
        for photo in self.photos {
            if !previousPhotoPaths.contains(photo.imagePath) {
                break
            }
            i += 1
        }
        if i == self.photos.count { i = 0 }
        showScreen(i)
        drawDots(i)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = (viewController as! ZoomController).index
        if (currentIndex == 0) {
            return nil
        }
        return zoomController(currentIndex-1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = (viewController as! ZoomController).index
        if (currentIndex == photos.count - 1) {
            return nil
        }
        return zoomController(currentIndex+1)
    }
    
    fileprivate func zoomController(_ newIndex: Int) -> ZoomController {
        let newView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZoomController") as! ZoomController
        let imageView = (newView.view.subviews[0] as! UIScrollView).subviews[0] as! UIImageView
        if newIndex >= photos.count {
            print("Trying to show non existent image in zoom controller")
        } else {
            imageView.image = photos[newIndex].image
            newView.image = photos[newIndex].image
        }
        newView.index = newIndex
        newView.owner = self
        return newView
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return photos.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return index
    }
    
    func drawDots(_ colourIndex: Int) {
        for dot in dots {
            dot.removeFromSuperview()
        }
        dots.removeAll()
        
        if (photos.count > 1) {
            let left = view.frame.width / 2 - (CGFloat(photos.count-1)) * 8
            for i in 0...photos.count-1 {
                let image = UIImage(named: "dot")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                let dot = UIImageView(image: image)
                dot.frame = CGRect(x: left + 16 * CGFloat(i), y: 45, width: 10, height: 10)
                dots.append(dot)
                view.addSubview(dot)
                if (i == colourIndex) {
                    dot.tintColor = UIColor.orange
                } else {
                    dot.tintColor = UIColor.lightGray
                }
            }
        }
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
        self.backButton!.center = CGPoint(x: 65, y: view.bounds.height - 60)
        self.backButton!.addTarget(self, action: #selector(ZoomSwipeController.goBack(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func createPhotoButton() {
        self.photoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        let image = UIImage(named: "camerablue")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.photoButton!.setImage(image, for: UIControlState())
        self.photoButton!.tintColor = UIColor.blue
        self.photoButton!.clipsToBounds = true
        self.photoButton!.layer.cornerRadius = 45.0
        self.photoButton!.layer.borderColor = UIColor.black.cgColor
        self.photoButton!.layer.borderWidth = 1.0
        self.photoButton!.backgroundColor = UIColor.white
        self.photoButton!.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height - 60)
        self.photoButton!.addTarget(self, action: #selector(ZoomSwipeController.photo(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func createDeleteButton() {
        self.deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let image = UIImage(named: "trash")
        self.deleteButton!.setImage(image, for: UIControlState())
        self.deleteButton!.clipsToBounds = true
        self.deleteButton!.layer.cornerRadius = 30.0
        self.deleteButton!.layer.borderColor = UIColor.black.cgColor
        self.deleteButton!.layer.borderWidth = 1.0
        self.deleteButton!.backgroundColor = UIColor.white
        self.deleteButton!.center = CGPoint(x: view.bounds.width - 65, y: view.bounds.height - 60)
        self.deleteButton!.addTarget(self, action: #selector(ZoomSwipeController.deletePhoto(_:)), for: UIControlEvents.touchUpInside)
    }

    func deletePhoto(_ sender : UIButton!) {
        photos[index].deletePhoto()
        photos.remove(at: index)
        if photos.count > 0 {
            showScreen(0)
        } else {
            goBack(nil)
        }
    }

    func photo(_ sender : UIButton!) {
        if (self.navigationController?.topViewController != self.mapController!.rephotoController) {
            self.mapController!.rephotoController.pinToRephoto = pinToRephoto
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(self.mapController!.rephotoController!, animated: false)
        }
    }
    
    func goBack(_ sender : UIButton!) {
        pinToRephoto!.refresh()
        self.navigationController!.popViewController(animated: false)
    }
    
    func showScreen(_ i: Int) {
        let startingViewController = zoomController(i)
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: false, completion: nil)
     
    }
}
