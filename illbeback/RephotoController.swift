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
    
    let addFlag = AddFlagController()
    var camera: Camera?
    var photoAlbum: PhotoAlbum?
    private var flagRepository: FlagRepository
    var pinToRephoto: MapPinView?
    
    init(photoAlbum: PhotoAlbum, flagRepository: FlagRepository) {
        self.photoAlbum = photoAlbum
        self.flagRepository = flagRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = Camera(
            navigationController: self.navigationController!,
            callback: { (controller, image, orientation) in self.addPhoto(image, orientation: orientation) }
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        camera!.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        camera!.stop()
    }
    
    func addPhoto(image: UIImage, orientation: UIDeviceOrientation) {
        flagRepository.save()
        photoAlbum!.addFlagImage(image, flag: pinToRephoto!.flag!)
//        navigationController?.popToRootViewControllerAnimated(true)
        navigationController?.popViewControllerAnimated(false)
        pinToRephoto!.refreshAndReopen()
    }
}