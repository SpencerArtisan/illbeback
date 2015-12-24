//
//  FlagCallout.swift
//  illbeback
//
//  Created by Spencer Ward on 22/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class FlagCallout: UIView {
    let WITHOUT_PHOTO = CGSize(width: 220.0, height: 270.0)
    let WITH_PORTRAIT_PHOTO = CGSize(width: 330.0, height: 280.0)
    let WITH_LANDSCAPE_PHOTO = CGSize(width: 270.0, height: 350.0)
    
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
    var annotationView: FlagAnnotationView!

    var imageUrl: String?
    var labelArea: CGRect?
    var calloutSize: CGSize?
    var photo: UIImage?
    
    var whenHeight: CGFloat = 0.0
    var fromHeight: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(flag: Flag, mapController: MapController, annotationView: FlagAnnotationView) {
        super.init(frame: CGRect(x:0, y:0, width: 0, height: 0))
        
        self.flag = flag
        self.mapController = mapController
        self.annotationView = annotationView
        self.imageUrl = mapController.photoAlbum.getMainPhoto(flag)?.imagePath
            
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
        
        frame = calloutFrame()
    }
    
    internal override func intrinsicContentSize() -> CGSize {
        return calloutSize!
    }
    
    private func calloutFrame() -> CGRect {
        return CGRect(
                    x: -calloutSize!.width/2 + 15,
                    y: -calloutSize!.height - 10,
                    width: calloutSize!.width,
                    height: calloutSize!.height)
    }

    func createLabelView() {
        labelView = UIView(frame: labelArea!)
        labelView!.backgroundColor = flag!.isPendingAccept() || flag!.isBlank() ? UIColor.lightGrayColor().colorWithAlphaComponent(0.3) : UIColor.whiteColor()
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
        
        if flag!.isPendingAccept()  || flag!.isBlank() {
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

    func isLandscape() -> Bool {
        return photo != nil && photo!.size.width > photo!.size.height
    }
    
    func createCalloutView() {
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 10
        addSubview(labelView!)
        if (photoView != nil) {
            addSubview(photoView!)
            addDotsToPhoto()
        }
        clipsToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.grayColor().CGColor
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
        if !flag!.isEvent() || flag?.originator() != Global.getUser().getName() {
            return
        }
        
        let barHeight = flag?.invitees().count > 2 ? CGFloat(18) : CGFloat(25)
        let fontSize = flag?.invitees().count > 2 ? CGFloat(12) : CGFloat(14)
        var count = 0
        for i in (flag?.invitees())! {
            var invitee = i
            if invitee.name() == Global.getUser().getName() { continue }
            count++
            if count == 4 && flag?.invitees().count > 4 {
                invitee = Invitee(name: "others")
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
        if flag!.isPendingAccept()  || flag!.isBlank() {
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
        if flag!.isPendingAccept()  || flag!.isBlank() {
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
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        
        if event!.type == UIEventType.Touches {
            if hitButton(point, button: acceptButton) {
                accept()
            } else if hitButton(point, button: declineButton) {
                decline()
            } else if hitPicture(point) {
                mapController?.zoomPicture(annotationView)
            } else if !flag!.isPendingAccept() {
                if hitButton(point, button: dateView) {
                    mapController?.rescheduleFlag(annotationView)
                } else if hitButton(point, button: deleteButton) {
                    mapController?.deleteFlag(annotationView)
                } else if hitButton(point, button: shareButton) {
                    mapController?.shareFlag(annotationView)
                } else if hitButton(point, button: photoButton) {
                    mapController?.rephotoMemory(annotationView)
                } else if hitButton(point, button: subtitleView) {
                    mapController?.rewordFlag(annotationView)
                }
            }
        }
        
        let view = super.hitTest(viewPoint, withEvent: event)
        
        return view
    }
    
    private func accept() {
        if flag!.isBlank() {
            mapController?.unblankFlag(annotationView)
        } else if flag!.isPendingAccept() {
            mapController?.acceptRecentShare(flag!)
        }
    }
    
    private func decline() {
        if flag!.isBlank() {
            mapController?.deleteFlag(annotationView)
        } else if flag!.isPendingAccept() {
            mapController?.declineRecentShare(flag!)
        }
    }
    
    private func hitButton(point: CGPoint, button: UIView?) -> Bool {
        return button != nil && button!.frame.contains(annotationView.convertPoint(point, toView: labelView))
    }
    
    private func hitPicture(point: CGPoint) -> Bool {
        return photoView != nil && photoView!.bounds.contains(self.convertPoint(point, toView: photoView))
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(bounds, point)
    }
}