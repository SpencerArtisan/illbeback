//
//  Camera.swift
//  illbeback
//
//  Created by Spencer Ward on 27/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation
import AVFoundation

class Camera : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {

    static var captureSession: AVCaptureSession?
    static var photoOutput: AVCapturePhotoOutput?
    static var rearCamera: AVCaptureDevice?
    static var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoCaptureCompletionBlock: ((UIImage?, Error?, UIDeviceOrientation?) -> Void)?
    
    var backButton: UIButton!
    var snapButton: UIButton!
    var libraryButton: UIButton!
    var navigationController: UINavigationController!
    var parentController: UIViewController!
    var callback: ((UINavigationController, UIImage, UIDeviceOrientation) -> Void)
    let imagePicker = UIImagePickerController()
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    init(navigationController: UINavigationController, callback: @escaping ((UINavigationController, UIImage, UIDeviceOrientation) -> Void)) {
        self.navigationController = navigationController
        self.parentController = navigationController.topViewController
        self.callback = callback
        super.init()
        createSnapButton()
        createLibraryButton()
        createBackButton()
        try? self.displayPreview(on: self.parentController.view)
   }
    
    static func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            //1
            let session = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
            guard let cameras = (session?.devices.flatMap { $0 }), !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            
            //2
            for camera in cameras {
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        func configureDeviceInputs() throws {
            //4
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                if self.captureSession!.canAddInput(self.rearCameraInput!) {
                    self.captureSession!.addInput(self.rearCameraInput!)
                    
                }
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
        }
        func configurePhotoOutput() throws {
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)
            
            if self.captureSession!.canAddOutput(self.photoOutput) {
                self.captureSession!.addOutput(self.photoOutput)
            }
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: Camera.captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }

    func start() {
        Utils.runOnUiThread {
            Camera.captureSession!.startRunning()
        }
            
        self.parentController.view.addSubview(self.snapButton)
        self.parentController.view.addSubview(self.libraryButton)
        self.parentController.view.addSubview(self.backButton)
    }
    
    func stop() {
    }
    
    func takePhoto(_ sender : UIButton!) {
        self.captureImage {(image, error, orientation) in
            self.takePhotoEffects()
            self.snapButton.removeFromSuperview()
            self.libraryButton.removeFromSuperview()
            self.callback(self.navigationController, image!, orientation!)
            Camera.captureSession!.stopRunning()
        }

    }
    
    func captureImage( completion: @escaping (UIImage?, Error?, UIDeviceOrientation?) -> Void) {
        self.photoCaptureCompletionBlock = completion

        let connection = Camera.photoOutput!.connection(withMediaType: AVMediaTypeVideo)
            switch UIDevice.current.orientation {
            case .portrait, .portraitUpsideDown:
                connection!.videoOrientation = .portrait
            case .landscapeRight:
                connection!.videoOrientation = .landscapeLeft
            case .landscapeLeft:
                connection!.videoOrientation = .landscapeRight
            default:
                connection!.videoOrientation = .portrait
            }
        
//        Camera.photoOutput.conn
        
//        if (connection?.isVideoOrientationSupported)! {
//            connection?.videoOrientation = currentVideoOrientation()
//        }
//
        Camera.photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?,
                        resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error, nil)
        } else if let buffer = photoSampleBuffer,
                    let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
                        let image = UIImage(data: data) {
            
            let orientation = UIDevice.current.orientation
            
//                    var modifiedImage = image
//                    if (orientation == UIDeviceOrientation.landscapeRight) {
//                        modifiedImage = image.rotateImage(image, onDegrees: 90)
//                    } else if (orientation == UIDeviceOrientation.landscapeLeft) {
//                        modifiedImage = image.rotateImage(image, onDegrees: -90)
//                    }
            self.photoCaptureCompletionBlock?(image, nil, orientation)
        } else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown, nil)
        }
    }
    
    func takePhotoEffects() {
        let blackView = blackout()
        
        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            blackView.layer.opacity = 1
        }, completion: {_ in
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                blackView.layer.opacity = 0
            }, completion: {_ in
                blackView.removeFromSuperview()
            })
        })
    }
    
    func blackout() -> UIView {
        let blackView = Bundle.main.loadNibNamed("Black", owner: self, options: nil)?[0] as? UIView
        let screenRect = UIScreen.main.bounds
        blackView!.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        self.parentController.view.addSubview(blackView!)
        blackView!.layer.opacity = 0
        return blackView!
    }

    func library(_ sender : UIButton!) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        parentController.present(imagePicker, animated: false, completion: nil)
    }
    
    func goBack(_ sender : UIButton!) {
        self.navigationController.popViewController(animated: false)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.snapButton.removeFromSuperview()
            parentController.dismiss(animated: false, completion: nil)

            print(navigationController.viewControllers.count)
            if navigationController.viewControllers.count == 2 {
                let zoomController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZoomController") as! ZoomController
                zoomController.image = pickedImage
                navigationController.pushViewController(zoomController, animated: false)
            }
            
            let devOrient = imageToDeviceOrientation(pickedImage)
            let correctedImage = pickedImage.fixOrientation()
            self.callback(navigationController, correctedImage!, devOrient)
        }
    }
    
    func toDeviceOrientation(_ image: UIImage) -> UIDeviceOrientation {
        if (image.size.width > image.size.height) { return UIDeviceOrientation.landscapeRight }
        return UIDeviceOrientation.faceUp
    }
    
    func toImageOrientation(_ image: UIImage) -> UIImageOrientation {
        if (image.size.width > image.size.height) { return UIImageOrientation.left }
        return UIImageOrientation.up
    }
    
    func imageToDeviceOrientation(_ image: UIImage) -> UIDeviceOrientation {
        if (image.imageOrientation == UIImageOrientation.up) { return UIDeviceOrientation.landscapeLeft }
        if (image.imageOrientation == UIImageOrientation.right) { return UIDeviceOrientation.portrait }
        if (image.imageOrientation == UIImageOrientation.down) { return UIDeviceOrientation.landscapeRight }
        
        return UIDeviceOrientation.faceUp
    }

    func createSnapButton() {
        self.snapButton = UIButton(type: UIButtonType.system)
        self.snapButton.frame = CGRect(x: 0, y: 0, width: 90.0, height: 90.0)
        self.snapButton.clipsToBounds = true
        self.snapButton.layer.cornerRadius = 45.0
        self.snapButton.layer.borderColor = UIColor.white.cgColor
        self.snapButton.layer.borderWidth = 2.0
        self.snapButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.snapButton.layer.rasterizationScale = UIScreen.main.scale
        self.snapButton.layer.shouldRasterize = true
        self.snapButton.addTarget(self, action: #selector(Camera.takePhoto(_:)), for: UIControlEvents.touchUpInside)
        self.snapButton.center = CGPoint(x: parentController.view.center.x, y: parentController.view.bounds.height - 66)
    }
    
    func createLibraryButton() {
        self.libraryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let image = UIImage(named: "Library")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.libraryButton!.setImage(image, for: UIControlState())
        self.libraryButton?.tintColor = UIColor.blue
        self.libraryButton.clipsToBounds = true
        self.libraryButton.layer.cornerRadius = 30.0
        self.libraryButton.layer.borderColor = UIColor.black.cgColor
        self.libraryButton.layer.borderWidth = 1.0
        self.libraryButton.backgroundColor = UIColor.white
        self.libraryButton.center = CGPoint(x: parentController.view.bounds.width - 65, y: parentController.view.bounds.height - 66)
        self.libraryButton.addTarget(self, action: #selector(Camera.library(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func createBackButton() {
        self.backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let image = UIImage(named: "back")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.backButton!.setImage(image, for: UIControlState())
        self.backButton!.tintColor = UIColor.blue
        self.backButton!.clipsToBounds = true
        self.backButton!.layer.cornerRadius = 30.0
        self.backButton!.layer.borderColor = UIColor.black.cgColor
        self.backButton!.layer.borderWidth = 1.0
        self.backButton!.backgroundColor = UIColor.white
        self.backButton.center = CGPoint(x: 65, y: parentController.view.bounds.height - 66)
        self.backButton!.addTarget(self, action: #selector(Camera.goBack(_:)), for: UIControlEvents.touchUpInside)
    }
}
