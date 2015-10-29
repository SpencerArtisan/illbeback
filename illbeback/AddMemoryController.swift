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
    var orientation: UIDeviceOrientation?
    var memoryId: String?
    var memoryImage: String?
    var memoryLocation: CLLocationCoordinate2D?
    var memories: MemoriesController?
    var callingViewController: UIViewController?
    var photoAlbum: PhotoAlbum?
    var rewordingMemory: Memory?
    var when: NSDate?

    init(album: PhotoAlbum, memoriesViewController: MemoriesController) {
        super.init(nibName: nil, bundle: nil)
        categoryModal = Modal(viewName: "CategoryView", owner: self)
        descriptionModal = Modal(viewName: "DescriptionView", owner: self)
        desciptionTextArea.delegate = self
        photoAlbum = album
        memories = memoriesViewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.desciptionTextArea.resignFirstResponder()
    }

    @IBAction func addCafe(sender: AnyObject) {
        addMemory("Cafe")
    }
    
    @IBAction func addRestaurant(sender: AnyObject) {
        addMemory("Restaurant")
    }
    
    @IBAction func addPub(sender: AnyObject) {
        addMemory("Bar")
    }
    
    @IBAction func addShop(sender: AnyObject) {
        addMemory("Shop")
    }
    
    @IBAction func addMuseum(sender: AnyObject) {
        addMemory("Museum")
    }

    @IBAction func addMusicVenue(sender: AnyObject) {
        addMemory("Music Venue")
    }
    
    @IBAction func addArtsVenue(sender: AnyObject) {
        addMemory("Arts Venue")
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
    
    @IBAction func addRemembrance(sender: AnyObject) {
        addMemory("Memory")
    }
    
    @IBAction func addGallery(sender: AnyObject) {
        addMemory("Gallery")
    }
    
    @IBAction func addEvent(sender: AnyObject) {
        addMemoryWithDate("Event")
    }
    
    @IBAction func cancel(sender: AnyObject) {
        hideCategorySelector()
        self.callingViewController!.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func add(controller: UIViewController, image: UIImage, orientation: UIDeviceOrientation) {
        print("Adding image at device orientation \(orientation.rawValue), size \(image.size)")
        rewordingMemory = nil
        self.memoryLocation = nil
        self.callingViewController = controller
        self.memoryId = NSUUID().UUIDString
        self.orientation = orientation
        self.photoAlbum!.saveMemoryImage(image, memoryId: self.memoryId!)
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
        let message = descriptionModal.findElementByTag(1) as! UILabel
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        datePicker().hidden = true
    
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }

    func showDescriptionEntryWithDate(type: String) {
        let message = descriptionModal.findElementByTag(1) as! UILabel
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        let when = datePicker()
        when.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        when.minimumDate = NSDate()
        when.maximumDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(31536000))
        when.hidden = false
        
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }
    
    func datePicker() -> UIDatePicker {
        return descriptionModal.findElementByTag(2) as! UIDatePicker
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            
            if (rewordingMemory != nil) {
                rewordingMemory?.description = textView.text
                memories!.memoryAlbum.save()
            } else {
                let when = datePicker().hidden ? nil as NSDate? : datePicker().date
                memories!.addMemoryHere(memoryImage!, id: memoryId!, description: textView.text, location: self.memoryLocation, orientation: self.orientation, when: when)
                self.callingViewController!.navigationController!.popToRootViewControllerAnimated(true)
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

    func addMemoryWithDate(type: String) {
        memoryImage = type
        showDescriptionEntryWithDate(type)
        hideCategorySelector()
    }
    
}