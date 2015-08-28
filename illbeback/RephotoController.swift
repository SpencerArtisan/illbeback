//
//  RephotoController.swift
//  illbeback
//
//  Created by Spencer Ward on 09/05/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

import UIKit

class RephotoController: UIViewController, UINavigationControllerDelegate {
    
    let addMemory = AddMemoryController()
    var camera: Camera?
    var photoAlbum: PhotoAlbum?
    var memoryAlbum: MemoryAlbum?
    var pinToRephoto: MapPinView?
    
    init(album: PhotoAlbum, memoryAlbum: MemoryAlbum) {
        super.init(nibName: nil, bundle: nil)
        photoAlbum = album
        self.memoryAlbum = memoryAlbum
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = Camera(parentController: self, callback: { (image, orientation) in self.replacePhoto(image, orientation: orientation) })
    }
    
    override func viewWillAppear(animated: Bool) {
        camera!.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        camera!.stop()
    }
    
    func replacePhoto(image: UIImage, orientation: UIDeviceOrientation) {
        pinToRephoto!.memory!.orientation = orientation
        self.memoryAlbum!.save()
        self.photoAlbum!.saveMemoryImage(image, memoryId: pinToRephoto!.memory!.id)
        self.navigationController?.popToRootViewControllerAnimated(true)
        pinToRephoto!.refreshAndReopen()
    }
}