//
//  FlagCallout.swift
//  illbeback
//
//  Created by Spencer Ward on 22/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    var lastHitTestPoint: CGPoint?
    
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
    
    fileprivate func reset() {
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
        labelView?.removeFromSuperview()
        
        labelView = UIView(frame: labelArea!)
        labelView!.backgroundColor = flag!.isPendingAccept() || flag!.isBlank() ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.white
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
        backgroundColor = UIColor.white
        layer.cornerRadius = 10
        addSubview(labelView!)
        if photoView != nil {
            addSubview(photoView!)
            addDotsToPhoto()
        }
        clipsToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.gray.cgColor
    }
    
    func createDeleteButton() {
        let x = photoView == nil ? labelArea!.width - 35 : labelArea!.width - 65
        deleteButton = UIButton(frame: CGRect(x: x, y: labelArea!.height - 39 - whenHeight, width: 40, height: 40))
        let image = UIImage(named: "trash")
        deleteButton!.setImage(image, for: UIControl.State())
    }
    
    func createShareButton() {
        if !flag!.isBlank() {
            let x = photoView == nil ? CGFloat(0) : CGFloat(30)
            shareButton = UIButton(frame: CGRect(x: x, y: labelArea!.height - 40 - whenHeight, width: 40, height: 40))
            let image = UIImage(named: "share")
            shareButton!.setImage(image, for: UIControl.State())
        }
    }
    
    func createPhotoButton() {
        if photoView == nil && !flag!.isBlank() {
            photoButton = UIButton(frame: CGRect(x: labelArea!.width / 2 - 17, y: labelArea!.height - 38 - whenHeight, width: 40, height: 40))
            let image = UIImage(named: "camera")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            photoButton!.setImage(image, for: UIControl.State())
            photoButton?.tintColor = UIColor.blue
        } else {
            photoButton = nil
        }
    }
    
    func addDotsToPhoto() {
        let count = mapController!.photoAlbum.photos(flag!).count
        
        if count > 1 {
            let left = photoView!.frame.width / 2 - (CGFloat(count-1)) * 6
            for i in 0...count-1 {
                let image = UIImage(named: "dot")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                let dot = UIImageView(image: image)
                dot.tintColor = UIColor.lightGray
                dot.frame = CGRect(x: left + 12 * CGFloat(i), y: 20, width: 8, height: 8)
                photoView!.addSubview(dot)
            }
        }
    }
    
    func createPhotoView() {
        photoView?.removeFromSuperview()

        if imageUrl != nil {
            photo = UIImage(contentsOfFile: imageUrl!)
            photoView = UIImageView(frame: CGRect(
                x: isLandscape() ? 0 : 0,
                y: isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 + 20: 0,
                width: isLandscape() ? WITH_LANDSCAPE_PHOTO.width - 0 : WITH_PORTRAIT_PHOTO.width/2 + 1,
                height: isLandscape() ? WITH_LANDSCAPE_PHOTO.height / 2 - 20: WITH_PORTRAIT_PHOTO.height))
            photoView!.image = photo
            photoView!.layer.borderWidth = 0.5
            photoView!.layer.borderColor = UIColor.gray.cgColor
        } else {
            photoView = nil
        }
    }
    
    func createDateLabel() {
        if (flag?.when() != nil) {
            whenHeight = 23
            dateView = createLabel(
                flag!.whenFormatted(),
                position: CGRect(x: 0, y: labelArea!.height-25, width: labelArea!.width, height: 25),
                fontSize: 14,
                italic: true,
                color: CategoryController.getColorForCategory(flag!.type()).withAlphaComponent(0.5))
        } else {
            dateView = nil
        }
    }
    
    func createTitleLabel() {
        titleView = createLabel(
            flag!.type(),
            position: CGRect(x: 0, y: 0, width: labelArea!.width, height: 40),
            fontSize: 20,
            italic: false,
            color: CategoryController.getColorForCategory(flag!.type()))
    }
    
    func createOriginatorLabel() {
        if (Global.getUser().getName() != flag?.originator()) { fromHeight = 25 }
        originatorView = createLabel(
            "from " + flag!.originator(),
            position: CGRect(x: 0, y: 40, width: labelArea!.width, height: 25),
            fontSize: 14,
            italic: true,
            color: CategoryController.getColorForCategory(flag!.type()).withAlphaComponent(0.5))
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
                count += 1
                if count == 3 && flag?.invitees().count > 4 { invitee = Invitee(name: "others") }
                
                let color = invitee.state() == InviteeState.Accepted ? UIColor.green.withAlphaComponent(0.6) :
                    (invitee.state() == InviteeState.Declined ? UIColor.red.withAlphaComponent(0.6) : UIColor.lightGray.withAlphaComponent(0.6))
                let state = invitee.state() == InviteeState.Accepted ? "accepted" : (invitee.state() == InviteeState.Declined ? "declined" : "invited")
                let InviteeLabel = createLabel(
                    "\(invitee.name()) \(state)",
                    position: CGRect(x: 0, y: 40 + fromHeight, width: labelArea!.width, height: barHeight),
                    fontSize: fontSize,
                    italic: true,
                    color: color)
                InviteeLabel.textColor = invitee.state() == InviteeState.Accepted ? UIColor.black : (invitee.state() == InviteeState.Declined ? UIColor.white : UIColor.darkGray)
                
                inviteeViews.append(InviteeLabel)
                fromHeight += barHeight
                
                if count == 3 { break }
            }
        }
    }

    func createSubtitleLabel() {
        subtitleView = createLabel(
            flag!.description().isEmpty ? "No description provided" : flag!.description(),
            position: CGRect(x: 6, y: 40 + fromHeight, width: labelArea!.width - 12, height: labelArea!.height - 74 - fromHeight - whenHeight),
            fontSize: 16,
            italic: false,
            color: UIColor.clear)
        subtitleView?.layer.borderWidth = 0
    }
    
    func createAcceptButton() {
        if flag!.isPendingAccept()  || flag!.isBlank() {
            acceptButton = createLabel(
                flag!.isBlank() ? "Use" : "Accept",
                position: CGRect(x: labelArea!.width / 2, y: labelArea!.height - 35 - whenHeight, width: labelArea!.width / 2, height: 35),
                fontSize: 18,
                italic: false,
                color: UIColor.green)
        } else {
            acceptButton = nil
        }
    }
    
    func createDeclineButton() {
        if flag!.isPendingAccept()  || flag!.isBlank() {
            declineButton = createLabel(
                flag!.isBlank() ? "Delete" : "Decline",
                position: CGRect(x: 0, y: labelArea!.height - 35 - whenHeight, width: labelArea!.width / 2, height: 35),
                fontSize: 18,
                italic: false,
                color:  UIColor.red.withAlphaComponent(0.5))
        }  else {
            declineButton = nil
        }
    }

    
    fileprivate func createLabel(_ text: String, position: CGRect, fontSize: CGFloat, italic: Bool, color: UIColor) -> UILabel {
        let label = UILabel(frame: position)
        label.layer.cornerRadius = 0
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.font = italic ? UIFont.italicSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.text = text
        label.backgroundColor = color
        label.textColor = UIColor.black
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.lightGray.cgColor
        return label
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convert(point, to: self) ?? point
        let duplicate = lastHitTestPoint != nil && lastHitTestPoint! == point
        
        if !duplicate && event!.type == UIEvent.EventType.touches {
            lastHitTestPoint = point
            if hitButton(point, button: acceptButton) {
                accept()
            } else if hitButton(point, button: declineButton) {
                decline()
            } else if hitPicture(point) {
                mapController?.zoomPicture(annotationView)
            } else if !flag!.isPendingAccept() && !flag!.isBlank() {
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
        
        let view = super.hitTest(viewPoint, with: event)
        
        return view
    }
    
    fileprivate func accept() {
        if flag!.isBlank() {
            mapController?.unblankFlag(annotationView)
        } else if flag!.isPendingAccept() {
            mapController?.acceptRecentShare(flag!)
        }
    }
    
    fileprivate func decline() {
        if flag!.isBlank() {
            mapController?.deleteFlag(annotationView)
        } else if flag!.isPendingAccept() {
            mapController?.declineRecentShare(flag!)
        }
    }
    
    fileprivate func hitButton(_ point: CGPoint, button: UIView?) -> Bool {
        return button != nil && button!.frame.contains(annotationView.convert(point, to: labelView))
    }
    
    fileprivate func hitPicture(_ point: CGPoint) -> Bool {
        return photoView != nil && photoView!.bounds.contains(annotationView.convert(point, to: photoView))
    }
}
