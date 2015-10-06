//
//  MapPinView.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import MapKit


class MapPinView: MKAnnotationView {
    let WITHOUT_PHOTO = CGSize(width: 220.0, height: 250.0)
    let WITH_PORTRAIT_PHOTO = CGSize(width: 330.0, height: 280.0)
    let WITH_LANDSCAPE_PHOTO = CGSize(width: 230.0, height: 310.0)
    
    var calloutView: UIView?
    var photoView: UIImageView?
    var labelView: UIView?
    
    var deleteButton: UIButton?
    var photoButton: UIButton?
    var shareButton: UIButton?

    var titleView: UILabel?
    var originatorView: UILabel?
    var acceptButton: UILabel?
    var declineButton: UILabel?
    var subtitleView: UILabel?

    var memoriesController:MemoriesController?
    var memory: Memory?
    var hitOutside: Bool = true
    var imageUrl: String?
    var labelArea: CGRect?
    var calloutSize: CGSize?
    
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
        let imageIcon = UIImage(named: memory!.type + " Flag")!

        let finalSize = CGSizeMake(imageIcon.size.width + 10, imageIcon.size.height + 10)
        UIGraphicsBeginImageContext(finalSize)
        imageIcon.drawInRect(CGRectMake(0, 10, imageIcon.size.width, imageIcon.size.height))
        
        let inShape: Bool = memoriesController!.shapeController.shapeContains(memory!.location)
        
        if (inShape) {
            let imageHighlight = UIImage(named: "share flag")!
            imageHighlight.drawInRect(CGRectMake(0, 0, imageHighlight.size.width, imageHighlight.size.height))
        } else if (memory!.recentShare) {
            let imageHighlight = UIImage(named: "recent")!
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
            
            labelArea = CGRect(
                x: photoView == nil ? 0 : (isLandscape() ? 0 : WITH_PORTRAIT_PHOTO.width / 2),
                y: 0,
                width: photoView == nil ? WITHOUT_PHOTO.width :
                    (isLandscape() ? WITH_LANDSCAPE_PHOTO.width : WITH_PORTRAIT_PHOTO.width / 2),
                height: photoView == nil ? WITHOUT_PHOTO.height :
                    (isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 + 20: WITH_PORTRAIT_PHOTO.height))

            calloutSize = CGSize(
                width: photoView == nil ? WITHOUT_PHOTO.width :
                    (isLandscape() ? WITH_LANDSCAPE_PHOTO.width : WITH_PORTRAIT_PHOTO.width),
                height: photoView == nil ? WITHOUT_PHOTO.height :
                    (isLandscape() ? WITH_LANDSCAPE_PHOTO.height : WITH_PORTRAIT_PHOTO.height))
            
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
        labelView = UIView(frame: labelArea!)
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
        self.calloutView?.frame = CGRect(
            x: -calloutSize!.width/2 + 15,
            y: -calloutSize!.height - 10,
            width: calloutSize!.width,
            height: calloutSize!.height)
        self.calloutView?.backgroundColor = UIColor.whiteColor()
        self.calloutView?.layer.cornerRadius = 10
        self.calloutView?.addSubview(labelView!)
        if (photoView != nil) {
            self.calloutView?.addSubview(photoView!)
            addDotsToPhoto()
        }
        self.calloutView?.clipsToBounds = true
        self.calloutView?.layer.borderWidth = 1.0
        self.calloutView?.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    func createDeleteButton() {
        deleteButton = UIButton(frame: CGRectMake(labelArea!.width - 35, labelArea!.height - 39, 40, 40))
        let image = UIImage(named: "trash")
        deleteButton!.setImage(image, forState: UIControlState.Normal)
    }
    
    func createPhotoButton() {
        photoButton = UIButton(frame: CGRectMake(labelArea!.width / 2 - 17, labelArea!.height - 38, 40, 40))
        let image = UIImage(named: "camera")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        photoButton!.setImage(image, forState: UIControlState.Normal)
        photoButton?.tintColor = UIColor.blueColor()
    }
    
    func addDotsToPhoto() {
        let count = memoriesController!.photoAlbum.photos(memory!).count
        
        let left = photoView!.frame.width / 2 - (CGFloat(count-1)) * 6
        for i in 0...count-1 {
            let dot = UIImageView(image: UIImage(named: "dot"))
            dot.frame = CGRectMake(left + 12 * CGFloat(i), 16, 5, 5)
            photoView!.addSubview(dot)
        }
    }
    
    func createShareButton() {
        shareButton = UIButton(frame: CGRectMake(0, labelArea!.height - 40, 40, 40))
        let image = UIImage(named: "share")
        shareButton!.setImage(image, forState: UIControlState.Normal)
    }
    
    func createPhotoView() {
        if (!NSFileManager.defaultManager().fileExistsAtPath(imageUrl!)) { return }
        let photo = UIImage(contentsOfFile: imageUrl!)
        photoView = UIImageView(frame: CGRectMake(
            isLandscape() ? 1 : 0,
            isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 + 17: 0,
            isLandscape() ? WITH_LANDSCAPE_PHOTO.width - 2 : WITH_PORTRAIT_PHOTO.width/2 + 1,
            isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 - 17 : WITH_PORTRAIT_PHOTO.height))
        photoView!.image = photo
        //        if (isLandscape()) {
        //            var angle = memory!.orientation == UIDeviceOrientation.LandscapeLeft ? -M_PI_2 : M_PI_2
        //            photoView?.transform = CGAffineTransformMakeRotation(CGFloat(angle))
        //        }
        photoView!.layer.borderWidth = 1
        photoView!.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    func createTitleLabel() {
        titleView = UILabel(frame: CGRectMake(0, 0, labelArea!.width, 40))
        titleView!.layer.cornerRadius = 0
        titleView!.numberOfLines = 0
        titleView!.textAlignment = NSTextAlignment.Center
        titleView!.font = titleView!.font.fontWithSize(20)
        titleView!.text = annotation!.title!
        titleView!.backgroundColor = CategoryController.getColorForCategory(memory!.type)
    }
    
    func createOriginatorLabel() {
        originatorView = UILabel(frame: CGRectMake(0, 40, labelArea!.width, 25))
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
        subtitleView = UILabel(frame: CGRectMake(10, 65, labelArea!.width - 20, labelArea!.height - 110))
        subtitleView!.backgroundColor = UIColor.whiteColor()
        subtitleView!.layer.cornerRadius = 0
        subtitleView!.numberOfLines = 0
        subtitleView!.textAlignment = NSTextAlignment.Center
        subtitleView!.text = memory!.description.isEmpty ? "No description provided" : memory!.description
    }
    
    func createAcceptButton() {
        acceptButton = UILabel(frame: CGRectMake(0, labelArea!.height - 40, labelArea!.width / 2, 40))
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
        declineButton = UILabel(frame: CGRectMake(labelArea!.width / 2, labelArea!.height - 40, labelArea!.width / 2, 40))
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
        } else {
            getCalloutView().removeFromSuperview()
        }
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)
        let system = NSProcessInfo.processInfo().systemUptime
        let elapsed = system - event!.timestamp
        if (elapsed < 0.1 && labelView != nil && hitView == nil && self.selected && event!.type == UIEventType.Touches) {
            hitView = calloutView!.hitTest(point, withEvent: event)
            if (memory!.recentShare && hitButton(point, button: acceptButton)) {
                memory!.recentShare = false;
                memoriesController?.updateMemory(self)
            } else if ((memory!.recentShare && hitButton(point, button: declineButton)) || hitButton(point, button: deleteButton)) {
                memoriesController?.deleteMemory(self)
            } else if (hitButton(point, button: shareButton)) {
                memoriesController?.shareController.shareMemory([self])
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
        return button != nil && button!.frame.contains(self.convertPoint(point, toView: labelView))
    }

    private func hitPicture(point: CGPoint) -> Bool {
        return photoView!.bounds.contains(self.convertPoint(point, toView: photoView))
    }
}