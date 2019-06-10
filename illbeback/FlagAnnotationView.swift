//
//  FlagAnnotationView.swift
//  illbeback
//
//  Created by Spencer Ward on 22/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import MapKit

class FlagAnnotationView : MKAnnotationView {
    class var reuseIdentifier:String {
        return "mapFlag"
    }
    
    var flag: Flag?
    fileprivate var mapController: MapController?
    fileprivate var calloutView:FlagCallout?
    fileprivate var clickedOnFlagOrCallout:Bool = false
    
    init(mapController: MapController, flag: Flag) {
        super.init(annotation: nil, reuseIdentifier: FlagAnnotationView.reuseIdentifier)
        canShowCallout = false
        self.isDraggable = true
        self.flag = flag
        self.mapController = mapController
        initImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshImage() {
        initImage()
    }
    
    func refresh() {
        if calloutView != nil { calloutView!.refresh() }
        initImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected || !selected && !clickedOnFlagOrCallout {
            super.setSelected(selected, animated: animated)
        } else {
            Utils.delay(0.1) { if self.annotation != nil { self.mapController?.map.selectAnnotation(self.annotation!, animated: false) } }
        }
        
        self.superview?.bringSubview(toFront: self)
        if self.isSelected { showCallout() }
        if !self.isSelected { hideCallout() }
    }
    
    fileprivate func showCallout() {
        let calloutOpen = calloutView?.superview != nil
        if !calloutOpen {
            calloutView = calloutView ?? FlagCallout(flag: flag!, mapController: mapController!, annotationView: self)
            addSubview(calloutView!)
            centreFlag()
            self.layer.zPosition = 2
        }
    }
    
    fileprivate func hideCallout() {
        calloutView?.removeFromSuperview()
        self.layer.zPosition = flag!.isEvent() ? 1 : 0
    }
    
    fileprivate func centreFlag() {
        let map = self.mapController!.map
        let pinCoord = flag!.location()
        let mapTopCoord = map?.convert(CGPoint(x: 0, y: 0), toCoordinateFrom: map)
        let mapBottomCoord = map?.convert(CGPoint(x: 0, y: (map?.frame.height)!), toCoordinateFrom: map)
        let coordsTopToBottom = (mapTopCoord?.latitude)! - (mapBottomCoord?.latitude)!
        let rescrollCoord = CLLocationCoordinate2D(latitude: (pinCoord.latitude + coordsTopToBottom/4), longitude: pinCoord.longitude)
        
        self.mapController?.map.setCenter(rescrollCoord, animated: true)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, with: event)
        
        if hitView == nil && self.isSelected {
            hitView = calloutView?.hitTest(point, with: event)
        }
        
        clickedOnFlagOrCallout = hitView != nil

        if clickedOnFlagOrCallout {
            disableSiblingSelectionTemporarily()
        }
        
        return hitView
    }
    
    fileprivate func disableSiblingSelectionTemporarily() {
        for annotation in (mapController?.map.annotations)! {
            if let siblingFlagAnnotation = annotation as? FlagAnnotation {
                if siblingFlagAnnotation.flag.id() != flag?.id() {
                    if let siblingFlagView = mapController?.map.view(for: siblingFlagAnnotation) {
                        siblingFlagView.isEnabled = false
                        Utils.delay(0.8) { siblingFlagView.isEnabled = true }
                    }
                }
            }
        }
    }
    
    fileprivate func initImage() {
        
        var imageIcon = UIImage(named: flag!.type() + " Flag")
        if imageIcon == nil {
            imageIcon = UIImage(named: "Blank Flag")
        }
        
        let finalSize = CGSize(width: imageIcon!.size.width + 10, height: imageIcon!.size.height + 10)
        UIGraphicsBeginImageContext(finalSize)
        imageIcon!.draw(in: CGRect(x: 0, y: 10, width: imageIcon!.size.width, height: imageIcon!.size.height))
        
        let inShape: Bool = mapController!.shapeController.shapeContains(flag!.location())
        
        if flag!.when() != nil {
            let daysToGo: NSString = " \(flag!.daysToGo()) " as NSString
            let col = flag!.daysToGo() < 6 ? UIColor.red : UIColor.gray
            daysToGo.draw(in: CGRect(x: 0,y: finalSize.height-14,width: 100,height: 30), withAttributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.backgroundColor: col,
                NSAttributedStringKey.font: UIFont(name: "Arial-BoldMT", size: 12)!
                ])
        }
        
        if (inShape) {
            let imageHighlight = UIImage(named: "share flag")!
            imageHighlight.draw(in: CGRect(x: 0, y: 0, width: imageHighlight.size.width, height: imageHighlight.size.height))
        } else if flag!.isPendingAccept() {
            let imageHighlight = UIImage(named: "recent")!
            imageHighlight.draw(in: CGRect(x: 0, y: 0, width: imageHighlight.size.width, height: imageHighlight.size.height))
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        centerOffset = CGPoint(x: 17, y: -20)
    }
}
