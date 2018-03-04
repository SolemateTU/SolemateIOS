//
//  ViewController.swift
//  Solemate
//
//  Created by Harjap Uppal on 2/18/18.
// modified by Bill Moriarty 3/3/2018
//  Copyright © 2018 Uppalled. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraRoll: UIButton!
    //augmented reality view provides live camera feed
    @IBOutlet var sceneView: ARSCNView!
    // temporary UI label to show results of on-device ML model
    @IBOutlet var mlText: UILabel!
    //view controller to choose an image
    var imagePicker = UIImagePickerController()
    
    var selectedImage: UIImage?
    var currentRecognizedObject: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        
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
        
        // Tap Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        //temporary UI label to display recognized object
        mlText.frame = CGRect(x: 0, y: self.sceneView.frame.height-300, width: self.sceneView.frame.width, height: 66)
        mlText.textAlignment = .center
        }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        //continuously check the ML model
        continuouslyUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //a forever loop to keep checking the on-phone ML model for what object is in the screen
    func continuouslyUpdate() {
        //use new thread
        DispatchQueue.global().async {
            self.detect()
            self.continuouslyUpdate()
        }
    }
    
    func updateMLlabel(results: String) {
        //use main thread - required
        DispatchQueue.main.sync {
            self.mlText.text = results
        }
    } // end updateMLlabel

    //function to handle when user taps on screen in AR
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // HIT TEST : REAL WORLD
        // Get Screen Centre
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint])
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            //create an augmented reality text label it at that position
            let labelNode = SCNText(string: self.currentRecognizedObject, extrusionDepth: CGFloat(0.01))
            labelNode.firstMaterial?.diffuse.contents = UIColor.white
            labelNode.font=UIFont(name: "Futura", size: 0.12)
            labelNode.chamferRadius = CGFloat(0.01)
            labelNode.alignmentMode = kCAAlignmentCenter

            let labelNodeParent = SCNNode(geometry: labelNode)
            labelNodeParent.scale = SCNVector3Make(0.2, 0.2, 0.2)
            labelNodeParent.position = worldCoord
            labelNodeParent.position.x = labelNodeParent.position.x/2
            labelNodeParent.position.y = labelNodeParent.position.y/2
            sceneView.scene.rootNode.addChildNode(labelNodeParent)
        }
    }

    
    //user has picked an image and now we want to do something with it
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]){
        //make sure an image was picked
        if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
        //if user is using camera, save the selected photo to camera roll
        if (imagePicker.sourceType == .camera)  {
            UIImageWriteToSavedPhotosAlbum(imagePicked, nil, nil, nil)
        }
        //set the selected image to be passed to server for recognition
        selectedImage = imagePicked
        //dismiss the image picker
        imagePicker.dismiss(animated: true, completion: nil)
    }
    }// end imagePickerController
    
    //method to query on-phone ML model by taking the ARKit sceneview's current frame
    func detect(){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("loading core ML model failed")
        }
        var firstResult = String ("")
        //get the current camera frame from the live AR session
        let tempImage : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if tempImage == nil { return }
        let tempciImage = CIImage(cvPixelBuffer: tempImage!)

        //initiate the request
        let request = VNCoreMLRequest(model: model) { (request, error) in
            //process the result of the request
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }
            //format the result into a string
            firstResult = results.first.flatMap({ $0 as VNClassificationObservation })
                .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })!
            print(firstResult )
        }
        //crop just the center of the captured camera frame to send to the ML model
        request.imageCropAndScaleOption=VNImageCropAndScaleOption.centerCrop
        
        let handler = VNImageRequestHandler(ciImage: tempciImage)
        do {
            //send the request to the model
            try handler.perform([request])
        } catch {
            print(error)
        }
        
        //update global currentRecognizedObject
        self.currentRecognizedObject = firstResult
        updateMLlabel(results: firstResult)
    } //end detect

    // when camera button is tapped, present this view controller to the user
    @IBAction func cameraTapped(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera //easiest way of implementing camera functionality in any app
        imagePicker.allowsEditing = false
        present (imagePicker, animated: true, completion: nil)
    }
    // when photo library button is tapped, present this view controller to the user

    @IBAction func photoLibraryTapped(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary //easiest way of implementing photo library functionality in any app
        imagePicker.allowsEditing = false
        present (imagePicker, animated: true, completion: nil)
    }
    
    
    }//end class ViewController
