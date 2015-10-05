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
    var dots: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    func setPhotoCount(count: Int) {
        let left = view.frame.width / 2 - (CGFloat(count-1)) * 8
        for i in 0...count-1 {
            let image = UIImage(named: "dot")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            let dot = UIImageView(image: image)
            dot.frame = CGRectMake(left + 16 * CGFloat(i), view.frame.height - 70, 8, 8)
            photo.addSubview(dot)
            dots.append(dot)
        }
        colourDot(0)
    }
    
    func colourDot(index: Int) {
        for dot in dots {
            dot.tintColor = UIColor.whiteColor()
        }
        dots[index].tintColor = UIColor.orangeColor()
    }
}