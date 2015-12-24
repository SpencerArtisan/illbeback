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
        
        print("Set selected to \(selected) to \(flag?.type()) (was \(self.selected))")
        
        if (selected || !selected && hitOutside) {
            print("Actioning...")
            super.setSelected(selected, animated: animated)
        } else {
            Utils.delay(0.1) {
                self.mapController?.map.selectAnnotation(self.annotation!, animated: false)
            }
        }
        
        self.superview?.bringSubviewToFront(self)
        
        if (calloutView == nil) {
            calloutView = FlagCallout(flag: flag!, mapController: mapController!)
        }
        
        if (self.selected && !calloutViewAdded) {
            print("Adding callout for \(flag?.type())")
            addSubview(calloutView!)
        }
        
        if (!self.selected) {
            print("Removing callout for \(flag?.type())")
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

        if !hitOutside {
            for annotation in (mapController?.map.annotations)! {
                if let siblingFlag = annotation as? FlagAnnotation {
                    if siblingFlag.flag.id() != flag?.id() {
                        if let xxx = mapController?.map.viewForAnnotation(siblingFlag) {
                            print("Disabling \(siblingFlag.flag.type())")
                            xxx.enabled = false
                            Utils.delay(0.8) {
                                xxx.enabled = true
                            }
//                            if xxx.selected {
//                                print("Auto deselecting \(flag.flag.type())")
//                                mapView.deselectAnnotation(annotation, animated: false)
//                            }
                        }
                    }
                }
            }
            
        }
        
//        if let flagView = view as? FlagAnnotationView {
//            print("SELECT \(flagView.flag?.type())")
//            
//        }

        //     print("hit outside = \(hitOutside)")
   
//        UIView *hitView = [super hitTest:point withEvent:event];
//        
//        if (hitView == self.accessory) {
//            [self preventParentSelectionChange];
//            [self performSelector:@selector(allowParentSelectionChange) withObject:nil afterDelay:1.0];
//            for (UIView *sibling in self.superview.subviews) {
//                if ([sibling isKindOfClass:[MKAnnotationView class]] && sibling != self.parentAnnotationView) {
//                    ((MKAnnotationView *)sibling).enabled = NO;
//                    [self performSelector:@selector(enableSibling:) withObject:sibling afterDelay:1.0];
//                }
//            }
//        }
        

        
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
