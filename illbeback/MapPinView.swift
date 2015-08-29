//
//  MapPinView.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import MapKit


class MapPinView: MKAnnotationView {
    let WIDTH: CGFloat = 330.0
    let HEIGHT: CGFloat = 280.0
    let WIDTH_WITHOUT_PHOTO: CGFloat = 220.0
    let HEIGHT_WITHOUT_PHOTO: CGFloat = 250.0
    let WIDTH_WITH_LANDSCAPE_PHOTO: CGFloat = 230.0
    let HEIGHT_WITH_LANDSCAPE_PHOTO: CGFloat = 310.0
    
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
    var originatorView: UILabel?
    var acceptButton: UILabel?
    var declineButton: UILabel?
    var labelView: UIView?
    var subtitleView: UILabel?
    var labelAreaWidth: CGFloat?
    var labelAreaHeight: CGFloat?
    var labelAreaLeft: CGFloat?
    var labelAreaTop: CGFloat?
    var calloutWidth: CGFloat?
    var calloutHeight: CGFloat?
    
    init(memoriesController: MemoriesController, memory: Memory, imageUrl: String?) {
        super.init(annotation: nil, reuseIdentifier: nil)

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
    
    func refreshImage() {
        initImage()
    }
    
    func initImage() {
        var imageIcon = UIImage(named: memory!.type + " Flag")!

        var finalSize = CGSizeMake(imageIcon.size.width + 10, imageIcon.size.height + 10)
        UIGraphicsBeginImageContext(finalSize)
        imageIcon.drawInRect(CGRectMake(0, 10, imageIcon.size.width, imageIcon.size.height))
        
        let inShape: Bool = memoriesController!.shapeController.shapeContains(memory!.location)
        
        if (inShape) {
            var imageHighlight = UIImage(named: "share flag")!
            imageHighlight.drawInRect(CGRectMake(0, 0, imageHighlight.size.width, imageHighlight.size.height))
        } else if (memory!.recentShare) {
            var imageHighlight = UIImage(named: "recent")!
            imageHighlight.drawInRect(CGRectMake(0, 0, imageHighlight.size.width, imageHighlight.size.height))
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        centerOffset = CGPointMake(17, -20)
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
            
            labelAreaWidth = photoView == nil ? WIDTH_WITHOUT_PHOTO : (isLandscape() ? WIDTH_WITH_LANDSCAPE_PHOTO : (WIDTH / 2))
            labelAreaHeight = photoView == nil ? HEIGHT_WITHOUT_PHOTO : (isLandscape() ? HEIGHT_WITH_LANDSCAPE_PHOTO / 2 + 20: HEIGHT)
            labelAreaLeft = photoView == nil ? 0 : (isLandscape() ? 0 : WIDTH / 2)
            labelAreaTop = 0
            calloutWidth = photoView == nil ? WIDTH_WITHOUT_PHOTO : (isLandscape() ? WIDTH_WITH_LANDSCAPE_PHOTO : WIDTH)
            calloutHeight = photoView == nil ? HEIGHT_WITHOUT_PHOTO : (isLandscape() ? HEIGHT_WITH_LANDSCAPE_PHOTO : HEIGHT)
            
            createSubtitleLabel()
            createTitleLabel()
            createOriginatorLabel()
            createDeleteButton()
            createPhotoButton()
            createShareButton()
            createAcceptButton()
            createDeclineButton()
            createLabelView()
            createCalloutView()
        }
        return calloutView!
    }
    
    func isLandscape() -> Bool {
        return memory?.orientation == UIDeviceOrientation.LandscapeLeft ||
               memory?.orientation == UIDeviceOrientation.LandscapeRight
    }
   
    func createLabelView() {
        labelView = UIView(frame: CGRectMake(labelAreaLeft!, labelAreaTop!, labelAreaWidth!, labelAreaHeight!))
        labelView!.backgroundColor = UIColor.whiteColor()
        labelView!.addSubview(titleView!)
        if (memoriesController?.user.getName() != memory?.originator) {
         labelView!.addSubview(originatorView!)
        }
        labelView!.addSubview(subtitleView!)
        
        if (memory!.recentShare) {
            labelView?.addSubview(acceptButton!)
            labelView?.addSubview(declineButton!)
        } else {
            labelView!.addSubview(deleteButton!)
            labelView!.addSubview(photoButton!)
            labelView!.addSubview(shareButton!)
        }
    }
    
    func createCalloutView() {
        self.calloutView = UIView()
        self.calloutView?.frame = CGRectMake(-calloutWidth!/2 + 15, -calloutHeight! - 10, calloutWidth!, calloutHeight!)
        self.calloutView?.backgroundColor = UIColor.whiteColor()
        self.calloutView?.layer.cornerRadius = 10
        self.calloutView?.addSubview(labelView!)
        if (photoView != nil) { self.calloutView?.addSubview(photoView!) }
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
        println("Loading image with orientation " + memory!.orientation.rawValue.description)
        photoView = UIImageView(frame: CGRectMake(
            isLandscape() ? 46 : 0,
            isLandscape() ? 129 : 0,
            isLandscape() ? HEIGHT_WITH_LANDSCAPE_PHOTO / 2 - 17 : WIDTH/2 + 1,
            isLandscape() ? WIDTH_WITH_LANDSCAPE_PHOTO - 2 : HEIGHT))
        photoView!.image = photo
        if (isLandscape()) {
            var angle = memory!.orientation == UIDeviceOrientation.LandscapeLeft ? -M_PI_2 : M_PI_2
            photoView?.transform = CGAffineTransformMakeRotation(CGFloat(angle))
        }
        photoView!.layer.borderWidth = 1
        photoView!.layer.borderColor = UIColor.grayColor().CGColor
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
    
    func createOriginatorLabel() {
        originatorView = UILabel(frame: CGRectMake(0, 40, labelAreaWidth!, 25))
        originatorView!.layer.cornerRadius = 0
        originatorView!.numberOfLines = 0
        originatorView!.textAlignment = NSTextAlignment.Center
        originatorView!.font = UIFont.italicSystemFontOfSize(14)
        originatorView!.text = "from " + memory!.originator
        originatorView!.backgroundColor = CategoryController.getColorForCategory(memory!.type).colorWithAlphaComponent(0.3)
        originatorView!.layer.borderWidth = 0.5
        originatorView!.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    func createSubtitleLabel() {
        subtitleView = UILabel(frame: CGRectMake(10, 65, labelAreaWidth! - 20, labelAreaHeight! - 110))
        subtitleView!.backgroundColor = UIColor.whiteColor()
        subtitleView!.layer.cornerRadius = 0
        subtitleView!.numberOfLines = 0
        subtitleView!.textAlignment = NSTextAlignment.Center
        subtitleView!.text = memory!.description.isEmpty ? "No description provided" : memory!.description
    }
    
    func createAcceptButton() {
        acceptButton = UILabel(frame: CGRectMake(0, labelAreaHeight! - 40, labelAreaWidth! / 2, 40))
        acceptButton!.layer.cornerRadius = 0
        acceptButton!.numberOfLines = 0
        acceptButton!.textAlignment = NSTextAlignment.Center
        acceptButton!.font = acceptButton!.font.fontWithSize(20)
        acceptButton!.text = "Accept"
        acceptButton!.backgroundColor = UIColor.greenColor()
        acceptButton!.layer.borderWidth = 1
        acceptButton!.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    func createDeclineButton() {
        declineButton = UILabel(frame: CGRectMake(labelAreaWidth! / 2, labelAreaHeight! - 40, labelAreaWidth! / 2, 40))
        declineButton!.layer.cornerRadius = 0
        declineButton!.numberOfLines = 0
        declineButton!.textAlignment = NSTextAlignment.Center
        declineButton!.font = declineButton!.font.fontWithSize(20)
        declineButton!.text = "Decline"
        declineButton!.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
        declineButton!.layer.borderWidth = 1
        declineButton!.layer.borderColor = UIColor.grayColor().CGColor
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
            if (memory!.recentShare && hitButton(point, button: acceptButton)) {
                memory!.recentShare = false;
                memoriesController?.updateMemory(self)
            } else if (memory!.recentShare && hitButton(point, button: declineButton)) {
                memoriesController?.deleteMemory(self)
            } else if (hitButton(point, button: deleteButton)) {
                memoriesController?.deleteMemory(self)
            } else if (hitButton(point, button: shareButton)) {
                memoriesController?.shareMemory(self)
            } else if (hitButton(point, button: photoButton)) {
                memoriesController?.rephotoMemory(self)
            } else if (hitButton(point, button: subtitleView)) {
                memoriesController?.rewordMemory(self)
            } else if (photoView != nil && hitPicture(point)) {
                memoriesController?.zoomPicture(self)
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

    private func hitPicture(point: CGPoint) -> Bool {
        var pt3 = self.convertPoint(point, toView: photoView)
        println("Clicked \(pt3.x),\(pt3.y)")
        println("Picture frame is \(photoView!.bounds)")
        println("Hit test result: \(photoView!.bounds.contains(pt3))")
        return photoView!.bounds.contains(pt3)
    }
}