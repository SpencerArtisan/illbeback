//
//  FirstViewController.swift
//  illbeback
//
//  Created by Spencer Ward on 02/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import UIKit

class RememberController: UIViewController, UINavigationControllerDelegate {

    var addFlag: AddFlagController?
    var camera: Camera?
    
    init(album: PhotoAlbum, mapController: MapController) {
        super.init(nibName: nil, bundle: nil)
        addFlag = AddFlagController(album: mapController.photoAlbum, mapController: mapController)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = Camera(
            navigationController: self.navigationController!,
            callback: {(controller, image, orientation) in self.addFlag!.add(controller.topViewController!, image: image, orientation: orientation)}
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        delay(0.01) {
            self.camera!.start()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        camera!.stop()
        addFlag?.viewWillDisappear(animated)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

