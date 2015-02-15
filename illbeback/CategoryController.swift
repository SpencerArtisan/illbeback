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
        println("Showing category")
    }
    
    class func getColorForCategory(category: String) -> UIColor {
        let categoryView = NSBundle.mainBundle().loadNibNamed("CategoryView", owner: self, options: nil)[0] as? UIView
        let buttons = categoryView?.subviews
        
        for button in buttons! {
            println(button.currentTitle!)
            var buttonTitle = button.currentTitle!!.uppercaseString as NSString
            if (buttonTitle.containsString(category.uppercaseString)) {
                return button.backgroundColor!!
            }
        }
        return UIColor.grayColor()
    }
}

