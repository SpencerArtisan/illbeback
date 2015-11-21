//
//  CategoryController.swift
//  illbeback
//
//  Created by Spencer Ward on 10/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CategoryController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    class func getColorForCategory(category: String) -> UIColor {
        let button = getButtonForCategory(category)
        return button == nil ? UIColor.whiteColor() : button!.backgroundColor!
    }

    class func getImageForCategory(category: String) -> UIImage {
        let button = getButtonForCategory(category)!
        return button.imageView!.image!
    }
    
    class func getButtonForCategory(category: String) -> UIButton? {
        let categoryView = NSBundle.mainBundle().loadNibNamed("CategoryView", owner: self, options: nil)[0] as? UIView
        let buttons = categoryView?.subviews
        
        for buttonx in buttons! {
            if let button = buttonx as? UIButton {
                if ((button.currentTitle) != nil) {
                    let buttonTitle = button.currentTitle!.uppercaseString as NSString
                    if buttonTitle.containsString(category.uppercaseString) {
                        return button
                    }
                }
            }
        }
        return nil
    }
}

