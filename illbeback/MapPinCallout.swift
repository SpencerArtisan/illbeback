//
//  MapPinCallout.swift
//  illbeback
//
//  Created by Spencer Ward on 15/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

class MapPinCallout: UIView {
    init() {
        super.init(frame: CGRectMake(0,0,150,200))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(let point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        return super.hitTest(viewPoint, withEvent: event)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(bounds, point)
    }
}
