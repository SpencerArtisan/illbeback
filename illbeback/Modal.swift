//
//  Modal.swift
//  illbeback
//
//  Created by Spencer Ward on 22/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

class Modal {
    fileprivate var view: UIView!
    fileprivate var preserveHeight: Bool
    fileprivate var _fromBottom: CGFloat = 0
    
    init(viewName: String, owner: UIViewController, preserveHeight: Bool) {
        self.view = Bundle.main.loadNibNamed(viewName, owner: owner, options: nil)?[0] as? UIView
        self.preserveHeight = preserveHeight
    }
    
    init(viewName: String, owner: UIViewController) {
        self.view = Bundle.main.loadNibNamed(viewName, owner: owner, options: nil)?[0] as? UIView
        self.preserveHeight = false
    }
    
    func fromBottom(_ value: CGFloat) {
        _fromBottom = value
    }
    
    func slideDownFromTop(_ parentView: UIView) {
        slideVertically(parentView, start: -75, end: 0, hide: false)
    }
    
    func slideUpFromTop(_ parentView: UIView) {
        slideVertically(parentView, start: 0, end: -75, hide: true)
    }
    
    func slideOutFromLeft(_ parentView: UIView) {
        slideHorizontally(parentView, start: -350, end: 0, hide: false)
    }

    func slideInFromLeft(_ parentView: UIView) {
        slideHorizontally(parentView, start: 0, end: -350, hide: true)
    }
    
    func slideOutFromRight(_ parentView: UIView) {
        slideHorizontally(parentView, start: 450, end: 0, hide: false)
    }
    
    func slideInFromRight(_ parentView: UIView) {
        slideHorizontally(parentView, start: 0, end: 450, hide: false)
    }
    
    func hide() {
        view.removeFromSuperview()
    }
    
    func findElementByTag(_ tag: Int) -> UIView? {
        return view.viewWithTag(tag)
    }
    
    func blurBackground() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.insertSubview(blurEffectView, at: 0)
        }
    }
    
    fileprivate func slideHorizontally(_ parentView: UIView, start: CGFloat, end: CGFloat, hide: Bool) {
        if self.view.superview == nil {
            parentView.addSubview(self.view)
            if preserveHeight {
                self.view.frame = CGRect(x: 0, y: parentView.frame.height - self.view.frame.height - _fromBottom,
                                                                    width: parentView.frame.width, height: self.view.frame.height)
            } else {
                self.view.frame = parentView.frame
            }
        } else {
            if preserveHeight {
                self.view.frame = CGRect(x: 0, y: parentView.frame.height - self.view.frame.height - _fromBottom,
                    width: parentView.frame.width, height: self.view.frame.height)
            }
        }
        self.view.frame.origin.x = start
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            var sliderFrame = self.view.frame
            sliderFrame.origin.x = end
            self.view.frame = sliderFrame
            }, completion: {_ in if hide { self.hide() } })
    }
    
    fileprivate func slideVertically(_ parentView: UIView, start: CGFloat, end: CGFloat, hide: Bool) {
        if self.view.superview == nil {
            parentView.addSubview(self.view)
            self.view.frame = CGRect(x: 0, y: 0, width: parentView.frame.width, height: self.view.frame.height)
        }
        self.view.frame.origin.y = start
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            var sliderFrame = self.view.frame
            sliderFrame.origin.y = end
            self.view.frame = sliderFrame
            }, completion: {_ in if hide { self.hide() } })
    }
}
