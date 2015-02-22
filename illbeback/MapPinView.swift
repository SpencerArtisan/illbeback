//
//  MapPinView.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import MapKit


class MapPinView: MKAnnotationView {
    let WIDTH: CGFloat = 320.0
    let HEIGHT: CGFloat = 280.0
    let WIDTH_WITHOUT_PHOTO: CGFloat = 130.0
    let HEIGHT_WITHOUT_PHOTO: CGFloat = 160.0
    
    var calloutView: UIView?
    var deleteButton: UIButton?
    var shareButton: UIButton?
    var hitOutside: Bool = true
    var memoriesController:MemoriesController?
    var memoryId: String?
    var imageUrl: String?
    var title: String?
    var subtitle: String?
    
    init(memoriesController: MemoriesController, memoryId: String, imageUrl: String?, title: String, subtitle: String) {
        super.init()

        self.memoryId = memoryId
        self.memoriesController = memoriesController
        self.imageUrl = imageUrl
        self.title = title
        self.subtitle = subtitle
        canShowCallout = false

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCalloutView() -> UIView {
        if (calloutView == nil) {
            let photoView = createPhotoView()
            let subtitleLabel = createSubtitleLabel(subtitle!)
            let titleLabel = createTitleLabel(title!)
            createDeleteButton()
            createShareButton()
            createCalloutView(photoView, title: titleLabel, subtitle: subtitleLabel)
            
        }
        return calloutView!
    }
    
    func createCalloutView(photo: UIView?, title: UIView, subtitle: UIView) {
        self.calloutView = UIView()
        if (photo == nil) {
            self.calloutView?.frame = CGRectMake(-WIDTH_WITHOUT_PHOTO/2, -HEIGHT_WITHOUT_PHOTO - 10, WIDTH_WITHOUT_PHOTO, HEIGHT_WITHOUT_PHOTO)
            self.calloutView?.backgroundColor = UIColor.whiteColor()
            self.calloutView?.layer.cornerRadius = 10
            title.frame = CGRectMake(0, 0, WIDTH_WITHOUT_PHOTO, 40)
            subtitle.frame = CGRectMake(0, 40, WIDTH_WITHOUT_PHOTO, HEIGHT_WITHOUT_PHOTO - 60)
            deleteButton!.frame = CGRectMake(WIDTH_WITHOUT_PHOTO-35,HEIGHT_WITHOUT_PHOTO-40,40,40)
        } else {
            self.calloutView?.frame = CGRectMake(-WIDTH/2, -HEIGHT - 10, WIDTH, HEIGHT)
            self.calloutView?.backgroundColor = UIColor.whiteColor()
            self.calloutView?.layer.cornerRadius = 10
            self.calloutView?.addSubview(photo!)
            self.calloutView?.addSubview(createBlankLabel())
        }
        self.calloutView?.addSubview(title)
        self.calloutView?.addSubview(subtitle)
        self.calloutView?.addSubview(deleteButton!)
        self.calloutView?.addSubview(shareButton!)
        self.calloutView?.clipsToBounds = true
        self.calloutView?.layer.borderWidth = 1.0
        self.calloutView?.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    func createDeleteButton() {
        deleteButton = UIButton(frame: CGRectMake(WIDTH-35,HEIGHT-40,40,40))
        var image = UIImage(named: "trash")
        
        deleteButton!.setImage(image, forState: UIControlState.Normal)
    }
    
    func createShareButton() {
        shareButton = UIButton(frame: CGRectMake(WIDTH/2,HEIGHT-40,40,40))
        var image = UIImage(named: "share")
        shareButton!.setImage(image, forState: UIControlState.Normal)
    }
    
    func createPhotoView() -> UIView? {
        if (!NSFileManager.defaultManager().fileExistsAtPath(imageUrl!)) { return nil }
        var photo = UIImage(contentsOfFile: imageUrl!)
        let photoView = UIImageView(frame: CGRectMake(0, 0, WIDTH/2 + 10, HEIGHT))
        photoView.image = photo
        return photoView
    }
    
    func createTitleLabel(title: String) -> UIView {
        let label = UILabel(frame: CGRectMake(WIDTH/2, 0, WIDTH/2, 40))
        label.layer.cornerRadius = 0
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.font = label.font.fontWithSize(20)
        label.text = title
        label.backgroundColor = CategoryController.getColorForCategory(title)
        return label
    }
    
    func createSubtitleLabel(subtitle: String) -> UIView {
        let label = UILabel(frame: CGRectMake(WIDTH/2 + 15, 40, WIDTH/2 - 30, HEIGHT - 60))
        label.backgroundColor = UIColor.whiteColor()
        label.layer.cornerRadius = 0
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.text = subtitle
        
        return label
    }

    func createBlankLabel() -> UIView {
        let label = UILabel(frame: CGRectMake(WIDTH/2, 40, WIDTH/2, HEIGHT - 40))
        label.backgroundColor = UIColor.whiteColor()
        label.layer.cornerRadius = 0
        label.clipsToBounds = true
        label.numberOfLines = 0
        
        return label
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if (self.selected) {
            addSubview(getCalloutView())
            self.superview?.bringSubviewToFront(getCalloutView())
        }
        
        if (!self.selected) {
            getCalloutView().removeFromSuperview()
        }
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)
        var system = NSProcessInfo.processInfo().systemUptime
        var elapsed = system - event!.timestamp
        if (elapsed < 0.1 && calloutView != nil && hitView == nil && self.selected && event!.type == UIEventType.Touches) {
            hitView = calloutView!.hitTest(point, withEvent: event)
            if (hitButton(point, button: deleteButton)) {
                memoriesController?.deleteMemory(self)
            }
            if (hitButton(point, button: shareButton)) {
                memoriesController?.shareMemory(self)
            }
        }
        
        hitOutside = hitView == nil
        return hitView
    }
    
    private func hitButton(point: CGPoint, button: UIButton?) -> Bool {
        if (button != nil) {
            var pt3 = self.convertPoint(point, toView: calloutView)
            if (button!.frame.contains(pt3)) {
                return true
            }
        }
        return false
    }

}