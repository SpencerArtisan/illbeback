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
    var rewordingMemory: Memory?

    init() {
        super.init(nibName: nil, bundle: nil)
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
    
    @IBAction func addMuseum(sender: AnyObject) {
        addMemory("Museum")
    }
    
    @IBAction func addLavatory(sender: AnyObject) {
        addMemory("Lavatory")
    }
    
    @IBAction func addBuilding(sender: AnyObject) {
        addMemory("Building")
    }
    
    @IBAction func addSpecial(sender: AnyObject) {
        addMemory("Special")
    }
    
    @IBAction func addGreenSpace(sender: AnyObject) {
        addMemory("Green Space")
    }
    
    @IBAction func addPlaceToStay(sender: AnyObject) {
        addMemory("Place to Stay")
    }
    
    func add(controller: UIViewController, image: UIImage) {
        rewordingMemory = nil
        self.memoryLocation = nil
        self.callingViewController = controller
        self.memoryId = NSUUID().UUIDString
        self.photoAlbum.saveMemoryImage(image, memoryId: self.memoryId!)
        self.showCategorySelector()
    }
   
    func add(controller: UIViewController, location: CLLocationCoordinate2D) {
        rewordingMemory = nil
        self.memoryLocation = location
        self.callingViewController = controller
        self.memoryId = NSUUID().UUIDString
        self.showCategorySelector()
    }
    
    func reword(controller: UIViewController, memory: Memory) {
        self.callingViewController = controller
        rewordingMemory = memory
        self.showDescriptionEntry(memory.type)
        desciptionTextArea.text = memory.description
    }
    
    func showCategorySelector() {
        categoryModal.slideOutFromLeft(self.callingViewController!.view)
    }
    
    func hideCategorySelector() {
        categoryModal.slideInFromLeft(self.callingViewController!.view)
    }
    
    func showDescriptionEntry(type: String) {
        var message = descriptionModal.findElementByTag(1) as! UILabel
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            var tabBarController = self.callingViewController!.parentViewController as! UITabBarController
            var memories = tabBarController.childViewControllers[0] as! MemoriesController
            
            if (rewordingMemory != nil) {
                rewordingMemory?.description = textView.text
                memories.memoryAlbum.save()
            } else {
                memories.addMemoryHere(memoryImage!, id: memoryId!, description: textView.text, location: self.memoryLocation)
                tabBarController.selectedIndex = 0
            }
            descriptionModal.hide()
            self.desciptionTextArea.text = ""
            return false
        }
        return true
    }
    
    func addMemory(type: String) {
        memoryImage = type
        showDescriptionEntry(type)
        hideCategorySelector()
    }

}