//
//  FirstViewController.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit

class RememberController: UIViewController, UINavigationControllerDelegate {

    var addMemory: AddMemoryController?
    var camera: Camera?
    
    init(album: PhotoAlbum) {
        super.init(nibName: nil, bundle: nil)
        addMemory = AddMemoryController(album: PhotoAlbum())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = Camera(parentController: self, callback: {image in self.addMemory!.add(self, image: image)})
    }
    
    override func viewWillAppear(animated: Bool) {
        camera!.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        camera!.stop()
    }
}

