//
//  MapPinView.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import MapKit


class MapPinView: MKAnnotationView {
    let WITHOUT_PHOTO = CGSize(width: 220.0, height: 270.0)
    let WITH_PORTRAIT_PHOTO = CGSize(width: 330.0, height: 280.0)
    let WITH_LANDSCAPE_PHOTO = CGSize(width: 270.0, height: 350.0)
    
    var calloutView: UIView?
    var photoView: UIImageView?
    var labelView: UIView?
    
    var deleteButton: UIButton?
    var photoButton: UIButton?
    var shareButton: UIButton?

    var titleView: UILabel?
    var dateView: UILabel?
    var originatorView: UILabel?
    var inviteeViews: [UILabel] = []
    var acceptButton: UILabel?
    var declineButton: UILabel?
    var subtitleView: UILabel?

    var mapController:MapController?
    var flag: Flag?
    var hitOutside: Bool = true
    var imageUrl: String?
    var labelArea: CGRect?
    var calloutSize: CGSize?
    var photo: UIImage?
    
    var whenHeight: CGFloat = 0.0
    var fromHeight: CGFloat = 0.0
    
    static var lastSelectionChange: NSDate?
    
    init(mapController: MapController, flag: Flag) {
        super.init(annotation: nil, reuseIdentifier: nil)

        self.flag = flag
        self.mapController = mapController
        self.imageUrl = mapController.photoAlbum.getMainPhoto(flag)?.imagePath

        canShowCallout = false
        annotation = annotation
        enabled = true
        draggable = true
        
        initImage()
    }
    
    func refreshAndReopen() {
        setSelected(false, animated: false)
        refresh()
        setSelected(true, animated: false)
    }

    func refresh() {
        fromHeight = 0
        whenHeight = 0
        calloutView = nil
        photoButton = nil
        titleView = nil
        dateView = nil
        inviteeViews = []
        photoView = nil
        shareButton = nil
        acceptButton = nil
        declineButton = nil
        labelView = nil
        self.imageUrl = mapController?.photoAlbum.getMainPhoto(flag!)?.imagePath
        refreshImage()
    }
    
    func refreshImage() {
        initImage()
    }
    
    private func initImage() {
        let imageIcon = UIImage(named: flag!.type() + " Flag")!

        let finalSize = CGSizeMake(imageIcon.size.width + 10, imageIcon.size.height + 10)
        UIGraphicsBeginImageContext(finalSize)
        imageIcon.drawInRect(CGRectMake(0, 10, imageIcon.size.width, imageIcon.size.height))
        
        let inShape: Bool = mapController!.shapeController.shapeContains(flag!.location())

        if flag!.when() != nil {
            let nearness = CGFloat(1.0 / (1.0 + log2(1.0 + CGFloat(flag!.daysToGo())/(61.0))))
            
            let daysToGo: NSString = " \(flag!.daysToGo()) "
            let col = UIColor(red: nearness, green: 1 - nearness, blue: 0, alpha: 0.8)
            daysToGo.drawInRect(CGRectMake(0,finalSize.height-14,100,30), withAttributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSBackgroundColorAttributeName: col,
                NSFontAttributeName: UIFont(name: "Arial-BoldMT", size: 12)!
            ])
        }
        
        if (inShape) {
            let imageHighlight = UIImage(named: "share flag")!
            imageHighlight.drawInRect(CGRectMake(0, 0, imageHighlight.size.width, imageHighlight.size.height))
        } else if pendingAccept() {
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
            
            createDateLabel()
            createOriginatorLabel()
            createInviteeLabel()
            createSubtitleLabel()
            createTitleLabel()
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
        return photo != nil && photo!.size.width > photo!.size.height
    }
   
    func createLabelView() {
        labelView = UIView(frame: labelArea!)
        labelView!.backgroundColor = pendingAccept() || flag!.isBlank() ? UIColor.lightGrayColor().colorWithAlphaComponent(0.3) : UIColor.whiteColor()
        labelView!.addSubview(titleView!)
        if (Global.getUser().getName() != flag?.originator()) {
         labelView!.addSubview(originatorView!)
        }
        for inviteeView in inviteeViews {
            labelView!.addSubview(inviteeView)
        }
        labelView!.addSubview(subtitleView!)
        if (flag?.when() != nil) {
            labelView!.addSubview(dateView!)
        }
        
        if pendingAccept()  || flag!.isBlank() {
            labelView?.addSubview(acceptButton!)
            labelView?.addSubview(declineButton!)
        } else {
            labelView!.addSubview(deleteButton!)
            if photoButton != nil {
                labelView!.addSubview(photoButton!)
            }
            if shareButton != nil {
                labelView!.addSubview(shareButton!)
            }
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
        let x = photoView == nil ? labelArea!.width - 35 : labelArea!.width - 65
        deleteButton = UIButton(frame: CGRectMake(x, labelArea!.height - 39 - whenHeight, 40, 40))
        let image = UIImage(named: "trash")
        deleteButton!.setImage(image, forState: UIControlState.Normal)
    }

    func createShareButton() {
        if !flag!.isBlank() {
            let x = photoView == nil ? CGFloat(0) : CGFloat(30)
            shareButton = UIButton(frame: CGRectMake(x, labelArea!.height - 40 - whenHeight, 40, 40))
            let image = UIImage(named: "share")
            shareButton!.setImage(image, forState: UIControlState.Normal)
        }
    }
    

    func createPhotoButton() {
        if photoView == nil && !flag!.isBlank() {
            photoButton = UIButton(frame: CGRectMake(labelArea!.width / 2 - 17, labelArea!.height - 38 - whenHeight, 40, 40))
            let image = UIImage(named: "camera")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            photoButton!.setImage(image, forState: UIControlState.Normal)
            photoButton?.tintColor = UIColor.blueColor()
        }
    }
    
    func addDotsToPhoto() {
        let count = mapController!.photoAlbum.photos(flag!).count
        
        if (count > 1) {
            let left = photoView!.frame.width / 2 - (CGFloat(count-1)) * 6
            for i in 0...count-1 {
                let image = UIImage(named: "dot")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                let dot = UIImageView(image: image)
                dot.tintColor = UIColor.lightGrayColor()
                dot.frame = CGRectMake(left + 12 * CGFloat(i), 20, 8, 8)
                photoView!.addSubview(dot)
            }
        }
    }
    
    func createPhotoView() {
        if (imageUrl == nil) { return }
        photo = UIImage(contentsOfFile: imageUrl!)
        photoView = UIImageView(frame: CGRectMake(
            isLandscape() ? 1 : 0,
            isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 + 20: 0,
            isLandscape() ? WITH_LANDSCAPE_PHOTO.width - 2 : WITH_PORTRAIT_PHOTO.width/2 + 1,
            isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 - 20: WITH_PORTRAIT_PHOTO.height))
        photoView!.image = photo
        photoView!.layer.borderWidth = 1
        photoView!.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    func createDateLabel() {
        if (flag?.when() != nil) {
            whenHeight = 23
        dateView = UILabel(frame: CGRectMake(0, labelArea!.height-25, labelArea!.width, 25))
        dateView!.layer.cornerRadius = 0
        dateView!.numberOfLines = 0
        dateView!.textAlignment = NSTextAlignment.Center
        dateView!.font = UIFont.italicSystemFontOfSize(14)
        dateView!.text = flag!.whenFormatted()
        dateView!.backgroundColor = CategoryController.getColorForCategory(flag!.type()).colorWithAlphaComponent(0.5)
        dateView!.layer.borderWidth = 0.5
        dateView!.layer.borderColor = UIColor.lightGrayColor().CGColor
        }
    }
    
    func createTitleLabel() {
        titleView = UILabel(frame: CGRectMake(0, 0, labelArea!.width, 40))
        titleView!.layer.cornerRadius = 0
        titleView!.numberOfLines = 0
        titleView!.textAlignment = NSTextAlignment.Center
        titleView!.font = titleView!.font.fontWithSize(20)
        titleView!.text = flag!.type()
        titleView!.backgroundColor = CategoryController.getColorForCategory(flag!.type())
        titleView!.layer.borderWidth = 0.5
        titleView!.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    func createOriginatorLabel() {
        if (Global.getUser().getName() != flag?.originator()) {
            fromHeight = 25
        }
        originatorView = UILabel(frame: CGRectMake(0, 40, labelArea!.width, 25))
        originatorView!.layer.cornerRadius = 0
        originatorView!.numberOfLines = 0
        originatorView!.textAlignment = NSTextAlignment.Center
        originatorView!.font = UIFont.italicSystemFontOfSize(14)
        originatorView!.text = "from " + flag!.originator()
        originatorView!.backgroundColor = CategoryController.getColorForCategory(flag!.type()).colorWithAlphaComponent(0.5)
        originatorView!.layer.borderWidth = 0.5
        originatorView!.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    func createInviteeLabel() {
        if !flag!.isEvent() {
            return
        }
        
        let barHeight = flag?.invitees().count > 2 ? CGFloat(18) : CGFloat(25)
        let fontSize = flag?.invitees().count > 2 ? CGFloat(12) : CGFloat(14)
        var count = 0
        for i in (flag?.invitees())! {
            var invitee = i
            count++
            if count == 4 && flag?.invitees().count > 4 {
                invitee = Invitee2(name: "others")
            }
            
            let inviteeView = UILabel(frame: CGRectMake(0, 40 + fromHeight, labelArea!.width, barHeight))
            inviteeView.layer.cornerRadius = 0
            inviteeView.numberOfLines = 0
            inviteeView.textAlignment = NSTextAlignment.Center
            inviteeView.font = UIFont.italicSystemFontOfSize(fontSize)
            let state = invitee.state() == InviteeState.Accepted ? "accepted" : (invitee.state() == InviteeState.Declined ? "declined" : "invited")
            inviteeView.text = "\(invitee.name()) \(state)"
            inviteeView.backgroundColor = invitee.state() == InviteeState.Accepted ? UIColor.greenColor().colorWithAlphaComponent(0.6) : (invitee.state() == InviteeState.Declined ? UIColor.redColor().colorWithAlphaComponent(0.6) : UIColor.lightGrayColor().colorWithAlphaComponent(0.6))
            inviteeView.textColor = invitee.state() == InviteeState.Accepted ? UIColor.blackColor() : (invitee.state() == InviteeState.Declined ? UIColor.whiteColor() : UIColor.darkGrayColor())
            inviteeView.layer.borderWidth = 0.5
            inviteeView.layer.borderColor = UIColor.lightGrayColor().CGColor
            inviteeViews.append(inviteeView)
            fromHeight += barHeight
            
            if count == 4 {
               break
            }
        }
    }
    
    func createSubtitleLabel() {
        subtitleView = UILabel(frame: CGRectMake(6, 40 + fromHeight, labelArea!.width - 12, labelArea!.height - 74 - fromHeight - whenHeight))
        subtitleView!.backgroundColor = UIColor.clearColor()
        subtitleView!.layer.cornerRadius = 0
        subtitleView!.numberOfLines = 0
        subtitleView!.textAlignment = NSTextAlignment.Center
        subtitleView!.text = flag!.description().isEmpty ? "No description provided" : flag!.description()
    }
    
    func createAcceptButton() {
        if pendingAccept()  || flag!.isBlank() {
            acceptButton = UILabel(frame: CGRectMake(labelArea!.width / 2, labelArea!.height - 35 - whenHeight, labelArea!.width / 2, 35))
            acceptButton!.layer.cornerRadius = 0
            acceptButton!.numberOfLines = 0
            acceptButton!.textAlignment = NSTextAlignment.Center
            acceptButton!.font = acceptButton!.font.fontWithSize(18)
            acceptButton!.text = flag!.isBlank() ? "Use" : "Accept"
            acceptButton!.backgroundColor = UIColor.greenColor()
            acceptButton!.layer.borderWidth = 1
            acceptButton!.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
    
    func createDeclineButton() {
        if pendingAccept()  || flag!.isBlank() {
            declineButton = UILabel(frame: CGRectMake(0, labelArea!.height - 35 - whenHeight, labelArea!.width / 2, 35))
            declineButton!.layer.cornerRadius = 0
            declineButton!.numberOfLines = 0
            declineButton!.textAlignment = NSTextAlignment.Center
            declineButton!.font = declineButton!.font.fontWithSize(18)
            declineButton!.text = flag!.isBlank() ? "Delete" : "Decline"
            declineButton!.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
            declineButton!.layer.borderWidth = 1
            declineButton!.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected && MapPinView.lastSelectionChange != nil && NSDate().timeIntervalSinceDate(MapPinView.lastSelectionChange!) < 0.7 {
            print("IGNORE SELECTION")
            Utils.delay(0.3) {
                self.mapController?.map.deselectAnnotation(self.annotation, animated: false)
            }
            return
        }
        
        if (self.selected) {
            //topLeft = [mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:mapView];

            let callout = getCalloutView()
            addSubview(callout)
            self.superview?.bringSubviewToFront(callout)
            
            let map = self.mapController!.map
            let pinCoord = flag!.location()
            let mapTopCoord = map.convertPoint(CGPointMake(0, 0), toCoordinateFromView: map)
            let mapBottomCoord = map.convertPoint(CGPointMake(0, map.frame.height), toCoordinateFromView: map)
            let coordsTopToBottom = mapTopCoord.latitude - mapBottomCoord.latitude
            let rescrollCoord = CLLocationCoordinate2D(latitude: (pinCoord.latitude + coordsTopToBottom/5), longitude: pinCoord.longitude)
            
            self.mapController?.map.setCenterCoordinate(rescrollCoord, animated: true)
        } else if MapPinView.lastSelectionChange != nil && NSDate().timeIntervalSinceDate(MapPinView.lastSelectionChange!) < 1 {
            print("IGNORE DESELECTION")
            Utils.delay(0.1) {
                if self.annotation != nil {
                    self.mapController?.map.selectAnnotation(self.annotation!, animated: false)
                }
            }
        } else {
            getCalloutView().removeFromSuperview()
        }
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)

        if hitButton(point, button: subtitleView) {
            MapPinView.lastSelectionChange = NSDate()
            print("Last selection")
        }
        let system = NSProcessInfo.processInfo().systemUptime
        let elapsed = system - event!.timestamp
        if (elapsed < 0.1 && labelView != nil && hitView == nil && self.selected && event!.type == UIEventType.Touches) {
            hitView = calloutView!.hitTest(point, withEvent: event)
            if acceptButton != nil && hitButton(point, button: acceptButton) {
                if flag!.isBlank() {
                    mapController?.unblankMemory(self)
                } else if pendingAccept() {
                    mapController?.acceptRecentShare(flag!)
                }
            } else if declineButton != nil && hitButton(point, button: declineButton) {
                if flag!.isBlank() {
                    mapController?.deleteMemory(self)
                } else if pendingAccept() {
                    mapController?.removePin(self)
                    mapController?.declineRecentShare(flag!)
                }
            } else if !pendingAccept() && hitButton(point, button: dateView) {
                mapController?.rescheduleMemory(self)
                MapPinView.lastSelectionChange = nil
            } else if !pendingAccept() && hitButton(point, button: deleteButton) {
                mapController?.deleteMemory(self)
            } else if !pendingAccept() && hitButton(point, button: shareButton) {
                mapController?.shareMemory(self)
            } else if !pendingAccept() && hitButton(point, button: photoButton) {
                mapController?.rephotoMemory(self)
            } else if !pendingAccept() && hitButton(point, button: subtitleView) {
                mapController?.rewordMemory(self)
                MapPinView.lastSelectionChange = nil
            } else if photoView != nil && hitPicture(point) {
                mapController?.zoomPicture(self)
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
    
    private func pendingAccept() -> Bool {
        return flag!.state() == .ReceivedUpdate || flag!.state() == .ReceivedNew ||  flag!.state() == .ReceivingUpdate || flag!.state() == .ReceivingNew
    }
}