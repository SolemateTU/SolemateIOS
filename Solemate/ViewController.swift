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
import ModelIO

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraRoll: UIButton!
    ///Augmented reality view provides live camera feed
    @IBOutlet var sceneView: ARSCNView!
    ///Temporary UI label to show results of on-device ML model
    @IBOutlet var mlText: UILabel!
    ///View controller to select an image from camera roll
    var imagePicker = UIImagePickerController()
    ///Holds the selected image to be sent to server
    var selectedImage: UIImage?
    ///Image view to show selected or captured image
    @IBOutlet weak var selectedView: UIImageView!
    var currentRecognizedObject: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        
        //capture button layout
        captureButton.layer.cornerRadius = 37.5
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
    
    /**
     A forever loop to keep checking the on-phone ML model for what object is in the screen. Runs 2 times per second
    */
    func continuouslyUpdate() {
         if self.selectedView.isHidden == true{
        //use new thread
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            self.detect()
            self.continuouslyUpdate()
            }
        }// end if
    }
    
    func updateMLlabel(results: String) {
        //use main thread - required
        DispatchQueue.main.sync {
            self.mlText.text = results
        }
    } // end updateMLlabel

    /**
     Handles selected image
        - sends it to server
        - pauses scene view
        - triggers pop up
     */
    func selectedImageHandler(){
            //shows the selected image
            selectedView.isHidden = false;
            selectedView.image = selectedImage
        
            //pauses the sceneview and hides it
            sceneView.pause(Any?.self)
            sceneView.isHidden = true;
        
            //Stop ML Model from running
            // I was able to do this by adding this: "if self.selectedView.isHidden == true" in func continuouslyUpdate()
        
            //Send to server
        
            //Trigger Pop Up
        
    }
    
    //handling the selection from camera roll
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        //make sure an image was picked
        if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage {
        //set the selected image to be passed to server for recognition
        selectedImage = imagePicked
        //dismiss the image picker
         selectedImageHandler()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    }// end imagePickerController
    
    //method to query on-phone ML model by taking the ARKit sceneview's current frame
    func detect(){
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else{
            fatalError("loading core ML model failed")
        }
        var firstResult = String ("")
        //get the current camera frame from the live AR session
        let tempImage : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if tempImage == nil { return }
        let tempciImage = CIImage(cvPixelBuffer: tempImage!)

        //initiate the request
        let request = VNCoreMLRequest(model: model) { (request, error) in }
        //crop just the center of the captured camera frame to send to the ML model
        request.imageCropAndScaleOption=VNImageCropAndScaleOption.centerCrop
        
        let handler = VNImageRequestHandler(ciImage: tempciImage)
        do {
            //send the request to the model
            try handler.perform([request])
        } catch {
            print(error)
        }
        
        //process the result of the request
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("model failed to process image")
        }
        //format the result into a string
        firstResult = results.first.flatMap({ $0 as VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })!
        //check if firstResult is a type of shoe. Strings taken from resnet50 models
        if (
            firstResult.range(of: "sandal") != nil ||
                firstResult.range(of: "Loafer") != nil  ||
                firstResult.range(of: "running shoe") != nil ||
                firstResult.range(of: "cowboy boot") != nil ||
                firstResult.range(of: "clog, geta, patten, sabot") != nil
            )
            { print(firstResult )
            //update global currentRecognizedObject
            self.currentRecognizedObject = firstResult
            updateMLlabel(results: firstResult)
            //display AR node near the shoe to be queried
            displayARShoe()
            }
        //reset the ui label to an empty string
        else {updateMLlabel(results: "")}
        
    } //end detect

    /**
     When capture button is tapped, it takes the picture and writes it to the camera roll
     - Parameters:
        - sender: captureButton
     */
    @IBAction func cameraTapped(_ sender: UIButton) {
        //erase the old shoe nodes so we only display one at a time
        eraseARNodes(nodeNameToErase: "shoe_node", sceneView: self.sceneView)
        
        selectedImage = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(selectedImage!, nil, nil, nil)
        //trigger the selected view
        selectedImageHandler()
    }
    
    /**
     When photo library button is tapped, This view controller is presented to the user
     
     - Parameters:
        - sender: cameraRoll button
     */
    @IBAction func photoLibraryTapped(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary //easiest way of implementing photo library functionality in any app
        imagePicker.allowsEditing = false
        present (imagePicker, animated: true, completion: nil)
        
    }
    
    //method to add AR shoe node near recognized shoe
    func displayARShoe() -> Void {
        
        
        //erase the old shoe nodes so we only display one at a time
        eraseARNodes(nodeNameToErase: "shoe_node", sceneView: self.sceneView)
        
//        self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in //this loops thru every node that's a child of the scene view's root node
//            if node.name == "shoe_node" {
//                //remove each node from their parent node (in this case the parent is the root)
//                node.removeFromParentNode()
//            }
//        })
        
        //load the ar shoe model
        let shoe_3d_scene = SCNScene(named: "art.scnassets/NikeAirmax_Lowpoly.scn")
        let shoe_3d_node = shoe_3d_scene?.rootNode.childNode(withName: "shoe_3d", recursively: false)
        
        guard let pointOfView = sceneView.pointOfView else {return} // sceneView.pointOfView is a Matrix of data
        let transform = pointOfView.transform
        //current location of the phone
        let orientation = SCNVector3(
            -transform.m31,
            -transform.m32,
            -transform.m33
        ) //m31 is 3rd column, 1st row
        //current location of the Camera
        let location = SCNVector3(
            transform.m41,
            transform.m42,
            transform.m43
        )
        //sum the positions
        let currentPositionOfCamera = sumSCNPositions(left: orientation, right: location)

        //shoe_3d_node = SCNNode(geometry:  SCNSphere(radius: 0.1))
        shoe_3d_node?.name = "shoe_node"
        //shoeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        shoe_3d_node?.position = currentPositionOfCamera
        self.sceneView.scene.rootNode.addChildNode(shoe_3d_node!)
        let rotateshoeNode = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 4)
        let forevershoeNode = SCNAction.repeatForever(rotateshoeNode)
        shoe_3d_node?.runAction(forevershoeNode)
    }
    
    }//end class ViewController

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
func sumSCNPositions(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func eraseARNodes(nodeNameToErase: String, sceneView: ARSCNView){
    //erase the old shoe nodes so we only display one at a time
    sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in //this loops thru every node that's a child of the scene view's root node
        if node.name == nodeNameToErase {
            //remove each node from their parent node (in this case the parent is the root)
            node.removeFromParentNode()
        }
    })
}
