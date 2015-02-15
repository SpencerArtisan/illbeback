//
//  MapPinView.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import MapKit


class MapPinView: MKAnnotationView {
    let WIDTH: CGFloat = 300.0
    let HEIGHT: CGFloat = 200.0
    var calloutView: UIView?
    var photoView: UIImageView?
    var label: UILabel?
    private var hitOutside:Bool = true
    
    init(photo: UIImage) {
        super.init()
        canShowCallout = false
        createPhoto(photo)
        createLabel()
        self.calloutView = UIView()
        photoView?.layer.cornerRadius = 10
        self.calloutView?.frame = CGRectMake(-WIDTH/2, -HEIGHT - 10, WIDTH, HEIGHT)
        self.calloutView?.backgroundColor = UIColor.whiteColor()
        self.calloutView?.layer.cornerRadius = 10
        self.calloutView?.addSubview(self.photoView!)
        self.calloutView?.addSubview(self.label!)
    }
    
    func createPhoto(photo: UIImage) {
        photoView = UIImageView(frame: CGRectMake(0, 0, WIDTH/2 + 10, HEIGHT))
        photoView?.layer.cornerRadius = 0
        photoView?.clipsToBounds = true
        photoView?.image = photo
    }
    
    func createLabel() {
        label = UILabel(frame: CGRectMake(WIDTH/2, 0, WIDTH/2 - 10, HEIGHT))
        label?.backgroundColor = UIColor.whiteColor()
        label?.layer.cornerRadius = 0
        label?.clipsToBounds = true
        label?.numberOfLines = 0
        label?.textAlignment = NSTextAlignment.Center
        label?.text = "hello\nthere"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if (self.selected) {
            addSubview(calloutView!)
            self.superview?.bringSubviewToFront(calloutView!)
        }
        
        if (!self.selected) {
            calloutView!.removeFromSuperview()
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
        
        return hitView;
    }

}