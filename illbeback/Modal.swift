//
//  Modal.swift
//  illbeback
//
//  Created by Spencer Ward on 22/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Modal {
    private var view: UIView!
    
    init(viewName: String, owner: UIViewController) {
        self.view = NSBundle.mainBundle().loadNibNamed(viewName, owner: owner, options: nil)[0] as? UIView
    }
    
    func slideOutFromLeft(parentView: UIView) {
        slide(parentView, start: -190, end: 0)
    }

    func slideInFromLeft(parentView: UIView) {
        slide(parentView, start: 0, end: -190)
    }
    
    func slideOutFromRight(parentView: UIView) {
        slide(parentView, start: 500, end: 190)
    }
    
    func hide() {
        view.removeFromSuperview()
    }
    
    func findElementByTag(tag: Int) -> UIView? {
        return view.viewWithTag(tag)
    }
    
    private func slide(parentView: UIView, start: CGFloat, end: CGFloat) {
        parentView.addSubview(self.view)
        self.view.frame.origin.x = start
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            var sliderFrame = self.view.frame
            sliderFrame.origin.x = end
            self.view.frame = sliderFrame
            }, completion: {_ in })
    }
}