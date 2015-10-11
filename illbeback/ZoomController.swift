//
//  ZoomController.swift
//  illbeback
//
//  Created by Spencer Ward on 10/05/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

import Foundation
import MapKit

class ZoomController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var photo: UIImageView!
    
    var index: Int = 0
    var owner : ZoomSwipeController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        owner?.index = index
        owner?.drawDots(index)
    }
}