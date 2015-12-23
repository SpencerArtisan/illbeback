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
    private var mapController: MapController?
    private var calloutView:FlagCallout?
    private var hitOutside:Bool = true
    
    var preventDeselection:Bool {
        return !hitOutside
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(mapController: MapController, flag: Flag) {
        super.init(annotation: nil, reuseIdentifier: FlagAnnotationView.reuseIdentifier)
        canShowCallout = false
        self.flag = flag
        self.mapController = mapController
        initImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshImage() {
        
    }
    
    func refresh() {
     
    }
    
    func refreshAndReopen() {
    
    }
  
    override func setSelected(selected: Bool, animated: Bool) {
        let calloutViewAdded = calloutView?.superview != nil
        
        if (selected || !selected && hitOutside) {
            super.setSelected(selected, animated: animated)
        }
        
        self.superview?.bringSubviewToFront(self)
        
        if (calloutView == nil) {
            calloutView = FlagCallout(flag: flag!, mapController: mapController!)
        }
        
        if (self.selected && !calloutViewAdded) {
            addSubview(calloutView!)
        }
        
        if (!self.selected) {
            calloutView?.removeFromSuperview()
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)
        
        if let callout = calloutView {
            if (hitView == nil && self.selected) {
                hitView = callout.hitTest(point, withEvent: event)
            }
        }
        
        hitOutside = hitView == nil
        print("hit outside = \(hitOutside)")
        
        return hitView;
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
        } else if flag!.isPendingAccept() {
            let imageHighlight = UIImage(named: "recent")!
            imageHighlight.drawInRect(CGRectMake(0, 0, imageHighlight.size.width, imageHighlight.size.height))
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        centerOffset = CGPointMake(17, -20)
    }
}
