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
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    class func getColorForCategory(_ category: String) -> UIColor {
        let button = getButtonForCategory(category)
        return button == nil ? UIColor.white : button!.backgroundColor!
    }

    class func getImageForCategory(_ category: String) -> UIImage {
        let button = getButtonForCategory(category)!
        return button.imageView!.image!
    }
    
    class func getButtonForCategory(_ category: String) -> UIButton? {
        let categoryView = Bundle.main.loadNibNamed("CategoryView", owner: self, options: nil)?[0] as? UIView
        let buttons = categoryView?.subviews
        
        for buttonx in buttons! {
            if let button = buttonx as? UIButton {
                if ((button.currentTitle) != nil) {
                    let buttonTitle = button.currentTitle!.uppercased() as NSString
                    if buttonTitle.contains(category.uppercased()) {
                        return button
                    }
                }
            }
        }
        return nil
    }
}

