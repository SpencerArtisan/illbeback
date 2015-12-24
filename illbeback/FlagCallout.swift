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
    let WITH_PORTRAIT_PHOTO = CGSize(width: 300.0, height: 260.0)
    let WITH_LANDSCAPE_PHOTO = CGSize(width: 260.0, height: 330.0)
    
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

        reset()
    }
    
    func refresh() {
        reset()
    }
    
    private func reset() {
        whenHeight = 0
        fromHeight = 0
        self.imageUrl = mapController!.photoAlbum.getMainPhoto(flag!)?.imagePath
        
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
        
        frame = CGRect(
            x: -calloutSize!.width/2 + 10,
            y: -calloutSize!.height - 2,
            width: calloutSize!.width,
            height: calloutSize!.height)
    }
    
    func createLabelView() {
        labelView = UIView(frame: labelArea!)
        labelView!.backgroundColor = flag!.isPendingAccept() || flag!.isBlank() ? UIColor.lightGrayColor().colorWithAlphaComponent(0.3) : UIColor.whiteColor()
        labelView!.addSubview(titleView!)
        if Global.getUser().getName() != flag?.originator() {
            labelView!.addSubview(originatorView!)
        }
        for inviteeView in inviteeViews {
            labelView!.addSubview(inviteeView)
        }
        labelView!.addSubview(subtitleView!)
        if flag?.when() != nil {
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
        if photoView != nil {
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
        } else {
            photoButton = nil
        }
    }
    
    func addDotsToPhoto() {
        let count = mapController!.photoAlbum.photos(flag!).count
        
        if count > 1 {
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
        if imageUrl != nil {
            photo = UIImage(contentsOfFile: imageUrl!)
            photoView = UIImageView(frame: CGRectMake(
                isLandscape() ? 0 : 0,
                isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 + 20: 0,
                isLandscape() ? WITH_LANDSCAPE_PHOTO.width - 0 : WITH_PORTRAIT_PHOTO.width/2 + 1,
                isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 - 20: WITH_PORTRAIT_PHOTO.height))
            photoView!.image = photo
            photoView!.layer.borderWidth = 0.5
            photoView!.layer.borderColor = UIColor.grayColor().CGColor
        } else {
            photoView = nil
        }
    }
    
    func createDateLabel() {
        if (flag?.when() != nil) {
            whenHeight = 23
            dateView = createLabel(
                flag!.whenFormatted(),
                position: CGRectMake(0, labelArea!.height-25, labelArea!.width, 25),
                fontSize: 14,
                italic: true,
                color: CategoryController.getColorForCategory(flag!.type()).colorWithAlphaComponent(0.5))
        } else {
            dateView = nil
        }
    }
    
    func createTitleLabel() {
        titleView = createLabel(
            flag!.type(),
            position: CGRectMake(0, 0, labelArea!.width, 40),
            fontSize: 20,
            italic: false,
            color: CategoryController.getColorForCategory(flag!.type()))
    }
    
    func createOriginatorLabel() {
        if (Global.getUser().getName() != flag?.originator()) { fromHeight = 25 }
        originatorView = createLabel(
            "from " + flag!.originator(),
            position: CGRectMake(0, 40, labelArea!.width, 25),
            fontSize: 14,
            italic: true,
            color: CategoryController.getColorForCategory(flag!.type()).colorWithAlphaComponent(0.5))
    }
    
    func createInviteeLabel() {
        inviteeViews = []
        if flag!.isEvent() && flag?.originator() == Global.getUser().getName() {
            let barHeight = flag?.invitees().count > 2 ? CGFloat(18) : CGFloat(25)
            let fontSize = flag?.invitees().count > 2 ? CGFloat(12) : CGFloat(14)
            var count = 0
            for i in (flag?.invitees())! {
                var invitee = i
                if invitee.name() == Global.getUser().getName() { continue }
                count++
                if count == 3 && flag?.invitees().count > 4 { invitee = Invitee(name: "others") }
                
                let color = invitee.state() == InviteeState.Accepted ? UIColor.greenColor().colorWithAlphaComponent(0.6) :
                    (invitee.state() == InviteeState.Declined ? UIColor.redColor().colorWithAlphaComponent(0.6) : UIColor.lightGrayColor().colorWithAlphaComponent(0.6))
                let state = invitee.state() == InviteeState.Accepted ? "accepted" : (invitee.state() == InviteeState.Declined ? "declined" : "invited")
                let InviteeLabel = createLabel(
                    "\(invitee.name()) \(state)",
                    position: CGRectMake(0, 40 + fromHeight, labelArea!.width, barHeight),
                    fontSize: fontSize,
                    italic: true,
                    color: color)
                InviteeLabel.textColor = invitee.state() == InviteeState.Accepted ? UIColor.blackColor() : (invitee.state() == InviteeState.Declined ? UIColor.whiteColor() : UIColor.darkGrayColor())
                
                inviteeViews.append(InviteeLabel)
                fromHeight += barHeight
                
                if count == 3 { break }
            }
        } else {
            dateView = nil
        }
    }

    func createSubtitleLabel() {
        subtitleView = createLabel(
            flag!.description().isEmpty ? "No description provided" : flag!.description(),
            position: CGRectMake(6, 40 + fromHeight, labelArea!.width - 12, labelArea!.height - 74 - fromHeight - whenHeight),
            fontSize: 16,
            italic: false,
            color: UIColor.clearColor())
        subtitleView?.layer.borderWidth = 0
    }
    
    func createAcceptButton() {
        if flag!.isPendingAccept()  || flag!.isBlank() {
            acceptButton = createLabel(
                flag!.isBlank() ? "Use" : "Accept",
                position: CGRectMake(labelArea!.width / 2, labelArea!.height - 35 - whenHeight, labelArea!.width / 2, 35),
                fontSize: 18,
                italic: false,
                color: UIColor.greenColor())
        } else {
            acceptButton = nil
        }
    }
    
    func createDeclineButton() {
        if flag!.isPendingAccept()  || flag!.isBlank() {
            declineButton = createLabel(
                flag!.isBlank() ? "Delete" : "Decline",
                position: CGRectMake(0, labelArea!.height - 35 - whenHeight, labelArea!.width / 2, 35),
                fontSize: 18,
                italic: false,
                color:  UIColor.redColor().colorWithAlphaComponent(0.5))
        }  else {
            declineButton = nil
        }
    }

    
    private func createLabel(text: String, position: CGRect, fontSize: CGFloat, italic: Bool, color: UIColor) -> UILabel {
        let label = UILabel(frame: position)
        label.layer.cornerRadius = 0
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.font = italic ? UIFont.italicSystemFontOfSize(fontSize) : UIFont.systemFontOfSize(fontSize)
        label.text = text
        label.backgroundColor = color
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.lightGrayColor().CGColor
        return label
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
        return photoView != nil && photoView!.bounds.contains(annotationView.convertPoint(point, toView: photoView))
    }
}