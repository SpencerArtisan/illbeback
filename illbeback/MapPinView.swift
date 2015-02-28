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
    
    var hitOutside: Bool = true
    var memoriesController:MemoriesController?
    var calloutView: UIView?
    var deleteButton: UIButton?
    var photoButton: UIButton?
    var shareButton: UIButton?
    var memory: Memory?
    var imageUrl: String?
    var photoView: UIImageView?
    var titleView: UILabel?
    var labelView: UIView?
    var subtitleView: UILabel?
    var labelAreaWidth: CGFloat?
    var labelAreaHeight: CGFloat?
    var labelAreaLeft: CGFloat?
    var calloutWidth: CGFloat?
    
    init(memoriesController: MemoriesController, memory: Memory, imageUrl: String?) {
        super.init()

        self.memory = memory
        self.memoriesController = memoriesController
        self.imageUrl = imageUrl

        canShowCallout = false
        annotation = annotation
        enabled = true
        draggable = true
        initImage()
    }
    
    func refreshAndReopen() {
        setSelected(false, animated: false)
        calloutView = nil
        setSelected(true, animated: false)
    }
    
    func refresh() {
        calloutView = nil
    }
    
    private func initImage() {
        var imageIcon = UIImage(named: memory!.type)!
        if (memory!.recentShare) {
            var imageHighlight = UIImage(named: "recent")!
            var finalSize = CGSizeMake(imageIcon.size.width * 3, imageIcon.size.height * 3)
            UIGraphicsBeginImageContext(finalSize)
            imageIcon.drawInRect(CGRectMake(imageIcon.size.width, imageIcon.size.height, imageIcon.size.width, imageIcon.size.height))
            imageHighlight.drawInRect(CGRectMake(11, 11, imageHighlight.size.width, imageHighlight.size.height))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()            
        } else {
            image = imageIcon
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCalloutView() -> UIView {
        if (calloutView == nil) {
            createPhotoView()
            labelAreaWidth = photoView == nil ? WIDTH_WITHOUT_PHOTO : WIDTH / 2
            labelAreaHeight = photoView == nil ? HEIGHT_WITHOUT_PHOTO : HEIGHT
            labelAreaLeft = photoView == nil ? 0 : WIDTH / 2
            calloutWidth = photoView == nil ? WIDTH_WITHOUT_PHOTO : WIDTH
            
            createSubtitleLabel()
            createTitleLabel()
            createDeleteButton()
            createPhotoButton()
            createShareButton()
            createLabelView()
            createCalloutView()
        }
        return calloutView!
    }
   
    func createLabelView() {
        labelView = UIView(frame: CGRectMake(labelAreaLeft!, 0, labelAreaWidth!, labelAreaHeight!))
        labelView!.backgroundColor = UIColor.whiteColor()
        labelView!.addSubview(titleView!)
        labelView!.addSubview(subtitleView!)
        labelView!.addSubview(deleteButton!)
        labelView!.addSubview(photoButton!)
        labelView!.addSubview(shareButton!)
    }
    
    func createCalloutView() {
        self.calloutView = UIView()
        self.calloutView?.frame = CGRectMake(-calloutWidth!/2 + 15, -labelAreaHeight! - 10, calloutWidth!, labelAreaHeight!)
        self.calloutView?.backgroundColor = UIColor.whiteColor()
        self.calloutView?.layer.cornerRadius = 10
        if (photoView != nil) { self.calloutView?.addSubview(photoView!) }
        self.calloutView?.addSubview(labelView!)
        self.calloutView?.clipsToBounds = true
        self.calloutView?.layer.borderWidth = 1.0
        self.calloutView?.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    func createDeleteButton() {
        deleteButton = UIButton(frame: CGRectMake(labelAreaWidth! - 35, labelAreaHeight! - 39, 40, 40))
        var image = UIImage(named: "trash")
        deleteButton!.setImage(image, forState: UIControlState.Normal)
    }
    
    func createPhotoButton() {
        photoButton = UIButton(frame: CGRectMake(labelAreaWidth! / 2 - 17, labelAreaHeight! - 38, 40, 40))
        var image = UIImage(named: "camera")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        photoButton!.setImage(image, forState: UIControlState.Normal)
        photoButton?.tintColor = UIColor.blueColor()
    }
    
    func createShareButton() {
        shareButton = UIButton(frame: CGRectMake(0, labelAreaHeight! - 40, 40, 40))
        var image = UIImage(named: "share")
        shareButton!.setImage(image, forState: UIControlState.Normal)
    }
    
    func createPhotoView() {
        if (!NSFileManager.defaultManager().fileExistsAtPath(imageUrl!)) { return }
        var photo = UIImage(contentsOfFile: imageUrl!)
        photoView = UIImageView(frame: CGRectMake(0, 0, WIDTH/2 + 10, HEIGHT))
        photoView!.image = photo
    }
    
    func createTitleLabel() {
        titleView = UILabel(frame: CGRectMake(0, 0, labelAreaWidth!, 40))
        titleView!.layer.cornerRadius = 0
        titleView!.numberOfLines = 0
        titleView!.textAlignment = NSTextAlignment.Center
        titleView!.font = titleView!.font.fontWithSize(20)
        titleView!.text = annotation.title
        titleView!.backgroundColor = CategoryController.getColorForCategory(memory!.type)
    }
    
    func createSubtitleLabel() {
        subtitleView = UILabel(frame: CGRectMake(10, 40, labelAreaWidth! - 20, labelAreaHeight! - 70))
        subtitleView!.backgroundColor = UIColor.whiteColor()
        subtitleView!.layer.cornerRadius = 0
        subtitleView!.numberOfLines = 0
        subtitleView!.textAlignment = NSTextAlignment.Center
        subtitleView!.text = memory!.description.isEmpty ? "No description provided" : memory!.description
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
        if (elapsed < 0.1 && labelView != nil && hitView == nil && self.selected && event!.type == UIEventType.Touches) {
            hitView = calloutView!.hitTest(point, withEvent: event)
            if (hitButton(point, button: deleteButton)) {
                memoriesController?.deleteMemory(self)
            } else if (hitButton(point, button: shareButton)) {
                memoriesController?.shareMemory(self)
            } else if (hitButton(point, button: photoButton)) {
                memoriesController?.rephotoMemory(self)
            } else if (hitButton(point, button: subtitleView)) {
                memoriesController?.rewordMemory(self)
            }
        }
        
        hitOutside = hitView == nil
        return hitView
    }
    
    private func hitButton(point: CGPoint, button: UIView?) -> Bool {
        if (button != nil) {
            var pt3 = self.convertPoint(point, toView: labelView)
            if (button!.frame.contains(pt3)) {
                return true
            }
        }
        return false
    }
}