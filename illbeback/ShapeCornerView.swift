//
//  ShapeCornerView.swift
//  illbeback
//
//  Created by Spencer Ward on 29/08/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import MapKit


class ShapeCornerView : MKAnnotationView {
    var mapController:MapController?
    
    init(mapController: MapController) {
        super.init(annotation: nil, reuseIdentifier: nil)
        
        self.mapController = mapController
        
        canShowCallout = false
        enabled = true
        draggable = true
        initImage()
    }
    
    private func initImage() {
        image = UIImage(named: "Shape Corner")!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}