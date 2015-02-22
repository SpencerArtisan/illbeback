//
//  AddMemory.swift
//  illbeback
//
//  Created by Spencer Ward on 16/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class AddMemoryController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var desciptionTextArea: UITextView!
    var categoryModal: Modal!
    var descriptionModal: Modal!
    var memoryId: String?
    var memoryImage: String?
    var memoryLocation: CLLocationCoordinate2D?
    var callingViewController: UIViewController?
    let photoAlbum = PhotoAlbum()

    override init() {
        super.init()
        categoryModal = Modal(viewName: "CategoryView", owner: self)
        descriptionModal = Modal(viewName: "DescriptionView", owner: self)
        desciptionTextArea.delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

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
    
    func add(controller: UIViewController, image: UIImage) {
        self.memoryLocation = nil
        self.callingViewController = controller
        self.memoryId = NSUUID().UUIDString
        self.photoAlbum.saveMemoryImage(image, memoryId: self.memoryId!)
        self.showCategorySelector()
    }
   
    func add(controller: UIViewController, location: CLLocationCoordinate2D) {
        self.memoryLocation = location
        self.callingViewController = controller
        self.memoryId = NSUUID().UUIDString
        self.showCategorySelector()
    }
    
    func showCategorySelector() {
        categoryModal.slideOutFromLeft(self.callingViewController!.view)
    }
    
    func hideCategorySelector() {
        categoryModal.slideInFromLeft(self.callingViewController!.view)
    }
    
    func showDescriptionEntry() {
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            var tabBarController = self.callingViewController!.parentViewController as UITabBarController
            var memories = tabBarController.childViewControllers[0] as MemoriesController
            
            memories.addMemoryHere(memoryImage!, id: memoryId!, description: textView.text, location: self.memoryLocation)
            tabBarController.selectedIndex = 0
            categoryModal.hide()
            descriptionModal.hide()
            self.desciptionTextArea.text = ""
            return false
        }
        return true
    }
    
    func addMemory(image: String) {
        memoryImage = image
        showDescriptionEntry()
        hideCategorySelector()
    }

}