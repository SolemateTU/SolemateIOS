//
//  ViewController.swift
//  Solemate
//
//  Created by Harjap Uppal on 2/18/18.
//  Copyright © 2018 Uppalled. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    //Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraRoll: UIButton!
    @IBOutlet weak var selectedView: UIImageView!
    
    //Camera
    var captureSession: AVCaptureSession?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var selectedImage: UIImage?
    
    //Camera Roll
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedView.isHidden = true
        //imagePicker
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate

        //capture button layout
        captureButton.layer.cornerRadius = captureButton.frame.size.width / 2
        captureButton.layer.shadowRadius = 3
        captureButton.layer.shadowColor = UIColor.black.cgColor
        captureButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        captureButton.layer.shadowOpacity = 0.8
        captureButton.clipsToBounds = false
        
        //camera roll button layout
        cameraRoll.layer.cornerRadius = 15
        cameraRoll.layer.shadowRadius = 3
        cameraRoll.layer.shadowColor = UIColor.black.cgColor
        cameraRoll.layer.shadowOffset = CGSize(width: 0, height: 2)
        cameraRoll.layer.shadowOpacity = 0.6
        cameraRoll.clipsToBounds = false
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("No video device found")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object
            captureSession = AVCaptureSession()
            
            // Set the input devcie on the capture session
            captureSession?.addInput(input)
            
            // Get an instance of ACCapturePhotoOutput class
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            
            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the input device
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self as? AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            //start session
            captureSession?.startRunning()
            
            
        } catch {
            print(error)
        }
    }

   /* override func viewDidLayoutSubviews() {
        videoPreviewLayer?.frame = view.bounds
        if let previewLayer = videoPreviewLayer ,(previewLayer.connection?.isVideoOrientationSupported)! {
            previewLayer.connection?.videoOrientation = UIApplication.shared.statusBarOrientation.videoOrientation ?? .portrait
        }
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions

    //Capture image on tap
    @IBAction func onTapCapture(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        // Set photo settings
        let photoSettings = AVCapturePhotoSettings()
        
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .off
        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    @IBAction func loadCameraRoll(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
}

// MARK: - AVCapturePhotoCaptureDelegate Functions
extension ViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        // Check if there is any error in capturing
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        
        // Check if the pixel buffer could be converted to image data
        guard let imageData = photo.fileDataRepresentation() else {
            print("Fail to convert pixel buffer")
            return
        }
        
        // Check if UIImage could be initialized with image data
        guard let capturedImage = UIImage.init(data: imageData , scale: 1.0) else {
            print("Fail to convert image data to UIImage")
            return
        }
        
       UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
       
        //set the selected image to be passed to server for recognition
        
        selectedImage = capturedImage
        previewView.isHidden = true
        captureSession?.stopRunning()
        selectedView.isHidden = false
        selectedView.image = capturedImage
        selectedView.contentMode = .scaleToFill
        // pop up
    }
    
    
    }

// MARK: - UIImagePickerControllerDelagate Functions
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        print("started")

       selectedView.isHidden = false
       selectedView.contentMode = .scaleAspectFit
       selectedView.image = pickedImage
       previewView.isHidden = true
        //set the selected image to be passed to server for recognition
        selectedImage = pickedImage
        captureSession?.stopRunning()
    }
       
        dismiss(animated: true, completion: nil)
}

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
}
    
}



