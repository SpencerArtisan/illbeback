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
    
    var calloutView: UIView!
    var hitOutside: Bool = true
    
    init(photo: UIImage, title: String, subtitle: String) {
        super.init()
        
        canShowCallout = false
        let photoView = createPhotoView(photo)
        let subtitleLabel = createSubtitleLabel(subtitle)
        let titleLabel = createTitleLabel(title)
        createCalloutView(photoView, title: titleLabel, subtitle: subtitleLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createCalloutView(photo: UIView, title: UIView, subtitle: UIView) {
        self.calloutView = UIView()
        self.calloutView.frame = CGRectMake(-WIDTH/2, -HEIGHT - 10, WIDTH, HEIGHT)
        self.calloutView.backgroundColor = UIColor.whiteColor()
        self.calloutView.layer.cornerRadius = 10
        self.calloutView.addSubview(photo)
        self.calloutView.addSubview(title)
        self.calloutView.addSubview(subtitle)
        self.calloutView.clipsToBounds = true
    }
    
    func createPhotoView(photo: UIImage) -> UIView {
        let photoView = UIImageView(frame: CGRectMake(0, 0, WIDTH/2 + 10, HEIGHT))
        photoView.layer.cornerRadius = 10
        photoView.clipsToBounds = true
        photoView.image = photo
        return photoView
    }
    
    func createTitleLabel(title: String) -> UIView {
        let label = UILabel(frame: CGRectMake(WIDTH/2, 0, WIDTH/2, 40))
        label.layer.cornerRadius = 0
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.backgroundColor = CategoryController.getColorForCategory(title)
        return label
    }
    
    func createSubtitleLabel(subtitle: String) -> UIView {
        let label = UILabel(frame: CGRectMake(WIDTH/2, 40, WIDTH/2 - 10, HEIGHT - 40))
        label.backgroundColor = UIColor.whiteColor()
        label.layer.cornerRadius = 0
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.text = subtitle
        return label
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