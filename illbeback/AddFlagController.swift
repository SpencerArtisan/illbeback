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
    var when: Date?
    var categoryShownAt: Date?

    init(album: PhotoAlbum, mapController: MapController) {
        super.init(nibName: nil, bundle: nil)
        categoryModal = Modal(viewName: "CategoryView", owner: self)
        descriptionModal = Modal(viewName: "DescriptionView", owner: self)
        desciptionTextArea.delegate = self
        photoAlbum = album
        self.mapController = mapController
    }
    
    @IBAction func cancelDescription(_ sender: AnyObject) {
        descriptionModal.hide()
        self.desciptionTextArea.text = ""
        self.callingViewController!.navigationController!.popToRootViewController(animated: true)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.desciptionTextArea.resignFirstResponder()
    }

    @IBAction func addCafe(_ sender: AnyObject) {
        addMemory("Cafe")
    }
    
    @IBAction func addRestaurant(_ sender: AnyObject) {
        addMemory("Restaurant")
    }
    
    @IBAction func addPub(_ sender: AnyObject) {
        addMemory("Bar")
    }
    
    @IBAction func addShop(_ sender: AnyObject) {
        addMemory("Shop")
    }
    
    @IBAction func addMuseum(_ sender: AnyObject) {
        addMemory("Museum")
    }

    @IBAction func addMusicVenue(_ sender: AnyObject) {
        addMemory("Music Venue")
    }
    
    @IBAction func addArtsVenue(_ sender: AnyObject) {
        addMemory("Arts Venue")
    }
    
    @IBAction func addLavatory(_ sender: AnyObject) {
        addMemory("Lavatory")
    }
    
    @IBAction func addBuilding(_ sender: AnyObject) {
        addMemory("Building")
    }
    
    @IBAction func addSpecial(_ sender: AnyObject) {
        addMemory("Special")
    }
    
    @IBAction func addGreenSpace(_ sender: AnyObject) {
        addMemory("Green Space")
    }
    
    @IBAction func addPlaceToStay(_ sender: AnyObject) {
        addMemory("Place to Stay")
    }
    
    @IBAction func addRemembrance(_ sender: AnyObject) {
        addMemory("Memory")
    }
    
    @IBAction func addGallery(_ sender: AnyObject) {
        addMemory("Gallery")
    }
    
    @IBAction func addEvent(_ sender: AnyObject) {
        addMemoryWithDate("Event")
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        if self.categoryShownAt == nil || Date().timeIntervalSince(categoryShownAt!) > 0.7 {
            categoryModal.hide()
            self.callingViewController!.navigationController!.popToRootViewController(animated: true)
        }
    }
    
    func add(_ controller: UIViewController, image: UIImage, orientation: UIDeviceOrientation) {
        print("Adding image at device orientation \(orientation.rawValue), size \(image.size)")
        rewordingPin = nil
        self.flagLocation = nil
        self.callingViewController = controller
        self.flagId = UUID().uuidString
        self.orientation = orientation
        self.photoAlbum!.saveFlagImage(image, flagId: self.flagId!)
        Utils.delay(0.2, closure: {
            self.showCategorySelector()
        })
    }
    
    func add(_ controller: UIViewController, location: CLLocationCoordinate2D) {
        rewordingPin = nil
        self.flagLocation = location
        self.callingViewController = controller
        self.flagId = UUID().uuidString
        self.showCategorySelector()
    }

    func addBlank(_ controller: UIViewController, location: CLLocationCoordinate2D, description: String) {
        mapController!.addFlagHere("Blank", id: UUID().uuidString, description: description, location: location, orientation: self.orientation, when: nil)
    }
    
    func reword(_ controller: UIViewController, pin: FlagAnnotationView) {
        self.callingViewController = controller
        rewordingPin = pin
        flagImage = pin.flag!.type()
        let flag = pin.flag!
        if flag.isEvent() {
            self.showDescriptionEntryWithDate(flag.type(), date: (flag.when() ?? Utils.today()) as Date)
        } else {
            self.showDescriptionEntry(flag.type())
        }
        desciptionTextArea.text = flag.description()
    }
    
    func reschedule(_ controller: UIViewController, pin: FlagAnnotationView) {
        reword(controller, pin: pin)
    }
    
    func unblank(_ controller: UIViewController, pin: FlagAnnotationView) {
        self.callingViewController = controller
        rewordingPin = pin

        self.showCategorySelector()
    }
    
    func showCategorySelector() {
        self.categoryShownAt = Date()
        categoryModal.slideOutFromLeft(self.callingViewController!.view)
    }
    
    func hideCategorySelector() {
        categoryModal.slideInFromLeft(self.callingViewController!.view)
    }
    
    func showDescriptionEntry(_ type: String) {
        let message = descriptionLabel()
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        datePicker().isHidden = true
    
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }

    func showDescriptionEntryWithDate(_ type: String, date: Date) {
        let message = descriptionLabel()
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        let when = datePicker()
        when.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        when.minimumDate = today()
        when.maximumDate = Date().addingTimeInterval(TimeInterval(31536000))
        when.setDate(date, animated: false)
        when.isHidden = false
        
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }
    
    func showDateEntry(_ type: String) {
        let message = descriptionLabel()
        message.backgroundColor = CategoryController.getColorForCategory(type)
        message.text = type
        let when = datePicker()
        when.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
        when.minimumDate = today()
        when.maximumDate = Date().addingTimeInterval(TimeInterval(31536000))
        when.setDate(today(),animated: false)
        when.isHidden = false
        
        descriptionModal.slideOutFromRight(self.callingViewController!.view)
        self.desciptionTextArea.becomeFirstResponder()
    }
    
    func today() -> Date {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        return cal.startOfDay(for: Date())
    }
    
    func datePicker() -> UIDatePicker {
        return descriptionModal.findElementByTag(2) as! UIDatePicker
    }
    
    func descriptionLabel() -> UILabel {
        return descriptionModal.findElementByTag(1) as! UILabel
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            
            let when = datePicker().isHidden ? nil as Date? : datePicker().date
            if (rewordingPin != nil) {
                let flag = rewordingPin!.flag!
                try! flag.description(textView.text)
                try! flag.when(when)
                flag.type(self.flagImage!)
                mapController!.flagRepository.save(flag)
                let annotation = rewordingPin!.annotation!
                print("add flag controller replacing pin")
                rewordingPin?.refreshImage()
            } else {
                mapController!.addFlagHere(flagImage!, id: flagId!, description: textView.text, location: self.flagLocation, orientation: self.orientation, when: when)
                self.callingViewController!.navigationController!.popToRootViewController(animated: true)
            }
            descriptionModal.hide()
            self.desciptionTextArea.text = ""
            return false
        }
        return true
    }
    
    func addMemory(_ type: String) {
        if self.categoryShownAt == nil || Date().timeIntervalSince(categoryShownAt!) > 0.7 {
            flagImage = type
            showDescriptionEntry(type)
            hideCategorySelector()
        }
    }

    func addMemoryWithDate(_ type: String) {
        if self.categoryShownAt == nil || Date().timeIntervalSince(categoryShownAt!) > 0.7 {
            flagImage = type
            showDescriptionEntryWithDate(type, date: today())
            hideCategorySelector()
        }
    }
    
}
