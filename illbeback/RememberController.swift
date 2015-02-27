//
//  FirstViewController.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit

class RememberController: UIViewController, UINavigationControllerDelegate {

    let addMemory = AddMemoryController()
    var camera: Camera?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = Camera(parentController: self, {image in self.addMemory.add(self, image: image)})
    }
    
    override func viewWillAppear(animated: Bool) {
        camera!.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        camera!.stop()
    }
}

