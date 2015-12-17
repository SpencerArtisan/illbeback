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
    private var preserveHeight: Bool
    private var _fromBottom: CGFloat = 0
    
    init(viewName: String, owner: UIViewController, preserveHeight: Bool) {
        self.view = NSBundle.mainBundle().loadNibNamed(viewName, owner: owner, options: nil)[0] as? UIView
        self.preserveHeight = preserveHeight
    }
    
    init(viewName: String, owner: UIViewController) {
        self.view = NSBundle.mainBundle().loadNibNamed(viewName, owner: owner, options: nil)[0] as? UIView
        self.preserveHeight = false
    }
    
    func fromBottom(value: CGFloat) {
        _fromBottom = value
    }
    
    func slideDownFromTop(parentView: UIView) {
        slideVertically(parentView, start: -75, end: 0, hide: false)
    }
    
    func slideUpFromTop(parentView: UIView) {
        slideVertically(parentView, start: 0, end: -75, hide: true)
    }
    
    func slideOutFromLeft(parentView: UIView) {
        slideHorizontally(parentView, start: -350, end: 0, hide: false)
    }

    func slideInFromLeft(parentView: UIView) {
        slideHorizontally(parentView, start: 0, end: -350, hide: true)
    }
    
    func slideOutFromRight(parentView: UIView) {
        slideHorizontally(parentView, start: 450, end: 0, hide: false)
    }
    
    func slideInFromRight(parentView: UIView) {
        slideHorizontally(parentView, start: 0, end: 450, hide: false)
    }
    
    func hide() {
        view.removeFromSuperview()
    }
    
    func findElementByTag(tag: Int) -> UIView? {
        return view.viewWithTag(tag)
    }
    
    private func slideHorizontally(parentView: UIView, start: CGFloat, end: CGFloat, hide: Bool) {
        if self.view.superview == nil {
            parentView.addSubview(self.view)
            if preserveHeight {
                self.view.frame = CGRectMake(0, parentView.frame.height - self.view.frame.height - _fromBottom,
                                                                    parentView.frame.width, self.view.frame.height)
            } else {
                self.view.frame = parentView.frame
            }
        } else {
            if preserveHeight {
                self.view.frame = CGRectMake(0, parentView.frame.height - self.view.frame.height - _fromBottom,
                    parentView.frame.width, self.view.frame.height)
            }
        }
        self.view.frame.origin.x = start
        
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            var sliderFrame = self.view.frame
            sliderFrame.origin.x = end
            self.view.frame = sliderFrame
            }, completion: {_ in if hide { self.hide() } })
    }
    
    private func slideVertically(parentView: UIView, start: CGFloat, end: CGFloat, hide: Bool) {
        if self.view.superview == nil {
            parentView.addSubview(self.view)
            self.view.frame = CGRectMake(0, 0, parentView.frame.width, self.view.frame.height)
        }
        self.view.frame.origin.y = start
        
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            var sliderFrame = self.view.frame
            sliderFrame.origin.y = end
            self.view.frame = sliderFrame
            }, completion: {_ in if hide { self.hide() } })
    }
}