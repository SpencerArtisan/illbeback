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
    fileprivate var flagRepository: FlagRepository
    var pinToRephoto: FlagAnnotationView?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        camera!.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        camera!.stop()
    }
    
    func addPhoto(_ image: UIImage, orientation: UIDeviceOrientation) {
        flagRepository.save()
        photoAlbum!.addFlagImage(image, flag: pinToRephoto!.flag!)
        navigationController?.popViewController(animated: false)
        pinToRephoto!.refresh()
    }
}
