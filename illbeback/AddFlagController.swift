//
//  AddMemory.swift
//  illbeback
//
//  Created by Spencer Ward on 16/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class AddFlagController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var desciptionTextArea: UITextView!
    var categoryModal: Modal!
    var descriptionModal: Modal!
    var orientation: UIDeviceOrientation?
    var flagId: String?
    var flagImage: String?
    var flagLocation: CLLocationCoordinate2D?
    var mapController: MapController?
    var callingViewController: UIViewController?
    var photoAlbum: PhotoAlbum?
    var rewordingPin: FlagAnnotationView?
    var when: NSDate?
    var categoryShownAt: NSDate?

    init(album: PhotoAlbum, mapController: MapController) {
        super.init(nibName: nil, bundle: nil)
        categoryModal = Modal(viewName: "CategoryView", owner: self)
        descriptionModal = Modal(viewName: "DescriptionView", owner: self)
        desciptionTextArea.delegate = self
        photoAlbum = album
        self.mapController = mapController
    }
    
    @IBAction func cancelDescription(sender: AnyObject) {
        descriptionModal.hide()
        self.desciptionTextArea.text = ""
        self.callingViewController!.navigationController!.popToRootViewControllerAnimated(true)
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
        if self.categoryShownAt == nil || NSDate().timeIntervalSinceDate(categoryShownAt!) > 0.7 {
            categoryModal.hide()
            self.callingViewController!.navigationController!.popToRootViewControllerAnimated(true)
        }
    }
    
    func add(controller: UIViewController, image: UIImage, orientation: UIDeviceOrientation) {
        print("Adding image at device orientation \(orientation.rawValue), size \(image.size)")
        rewordingPin = nil
        self.flagLocation = nil
        self.callingViewController = controller
        self.flagId = NSUUID().UUIDString
        self.orientation = orientation
        self.photoAlbum!.saveFlagImage(image, flagId: self.flagId!)
        self.showCategorySelector()
    }
    
    func add(controller: UIViewController, location: CLLocationCoordinate2D) {
        rewordingPin = nil
        self.flagLocation = location
        self.callingViewController = controller
        self.flagId = NSUUID().UUIDString
        self.showCategorySelector()
    }

    func addBlank(controller: UIViewController, location: CLLocationCoordinate2D, description: String) {
        mapController!.addFlagHere("Blank", id: NSUUID().UUIDString, description: description, location: location, orientation: self.orientation, when: nil)
    }
    
    func reword(controller: UIViewController, pin: FlagAnnotationView) {
        self.callingViewController = controller
        rewordingPin = pin
        flagImage = pin.flag!.type()
        let flag = pin.flag!
        if flag.isEvent() {
            self.showDescriptionEntryWithDate(flag.type(), date: flag.when()!)
        } else {
            self.showDescriptionEntry(flag.type())
        }
        desciptionTextArea.text = flag.description()
    }
    
    func reschedule(controller: UIViewController, pin: FlagAnnotationView) {
        reword(controller, pin: pin)
    }
    
    func unblank(controller: UIViewController, pin: FlagAnnotationView) {
        self.callingViewController = controller
        rewordingPin = pin

        self.showCategorySelector()
    }
    
    func showCategorySelector() {
        self.categoryShownAt = NSDate()
        categoryModal.slideOutFromLeft(self.callingViewController!.view)
    }
    
    func hideCategorySelector() {
        categoryModal.slideInFromLeft(self.callingViewController!.view)
    }
    
    func showDescriptionEntry(type: String) {
        let message = descriptionLabel()
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        datePicker().hidden = true
    
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }

    func showDescriptionEntryWithDate(type: String, date: NSDate) {
        let message = descriptionLabel()
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        let when = datePicker()
        when.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        when.minimumDate = today()
        when.maximumDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(31536000))
        when.setDate(date, animated: false)
        when.hidden = false
        
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }
    
    func showDateEntry(type: String) {
        let message = descriptionLabel()
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        let when = datePicker()
        when.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        when.minimumDate = today()
        when.maximumDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(31536000))
        when.setDate(today(),animated: false)
        when.hidden = false
        
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }
    
    func today() -> NSDate {
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        return cal.startOfDayForDate(NSDate())
    }
    
    func datePicker() -> UIDatePicker {
        return descriptionModal.findElementByTag(2) as! UIDatePicker
    }
    
    func descriptionLabel() -> UILabel {
        return descriptionModal.findElementByTag(1) as! UILabel
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            
            let when = datePicker().hidden ? nil as NSDate? : datePicker().date
            if (rewordingPin != nil) {
                try! rewordingPin?.flag?.description(textView.text)
                try! rewordingPin?.flag?.when(when)
                rewordingPin?.flag?.type(self.flagImage!)
                mapController!.flagRepository.save()
                let annotation = rewordingPin!.annotation!
                print("add flag controller replacing pin")
                rewordingPin?.refreshImage()
            } else {
                mapController!.addFlagHere(flagImage!, id: flagId!, description: textView.text, location: self.flagLocation, orientation: self.orientation, when: when)
                self.callingViewController!.navigationController!.popToRootViewControllerAnimated(true)
            }
            descriptionModal.hide()
            self.desciptionTextArea.text = ""
            return false
        }
        return true
    }
    
    func addMemory(type: String) {
        if self.categoryShownAt == nil || NSDate().timeIntervalSinceDate(categoryShownAt!) > 0.7 {
            flagImage = type
            showDescriptionEntry(type)
            hideCategorySelector()
        }
    }

    func addMemoryWithDate(type: String) {
        if self.categoryShownAt == nil || NSDate().timeIntervalSinceDate(categoryShownAt!) > 0.7 {
            flagImage = type
            showDescriptionEntryWithDate(type, date: today())
            hideCategorySelector()
        }
    }
    
}