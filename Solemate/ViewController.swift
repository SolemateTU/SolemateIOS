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
import MessageUI

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Main view components
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraRoll: UIButton!
    ///Augmented reality view provides live camera feed
    @IBOutlet var sceneView: ARSCNView!
    
    ///View controller to select an image from camera roll
    var imagePicker = UIImagePickerController()
    ///Holds the selected image to be sent to server
    var selectedImage: UIImage?
    ///Image view to show selected or captured image
    @IBOutlet weak var selectedView: UIImageView!
    var currentRecognizedObject: String = ""

    //Pop Up view components
    ///Pop Up View
    @IBOutlet weak var popUpView: UIView!
    ///top of popup view created by the constraints
    var topOfPopUp: CGFloat!
    ///Name of recognized shoe, returned from AWS
    @IBOutlet weak var recognizedName: UILabel!
     ///Image of recognized shoe, returned from AWS
    @IBOutlet weak var recognizedImage: UIImageView!
    
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
        cameraRoll.layer.cornerRadius = 17
        cameraRoll.layer.shadowRadius = 3
        cameraRoll.layer.shadowColor = UIColor.black.cgColor
        cameraRoll.layer.shadowOffset = CGSize(width: 0, height: 2)
        cameraRoll.layer.shadowOpacity = 0.6
        cameraRoll.clipsToBounds = false

        //pop up layout
        popUpView.layer.cornerRadius = 17
        //only add corner radius to top corners
        popUpView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        popUpView.layer.shadowRadius = 3
        popUpView.layer.shadowColor = UIColor.black.cgColor
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 0)
        popUpView.layer.shadowOpacity = 0.8
        topOfPopUp = popUpView.frame.origin.y
        //pop up image layout
        recognizedImage.layer.cornerRadius = 70
        recognizedImage.layer.borderWidth = 1;
        recognizedImage.layer.borderColor = UIColor.lightGray.cgColor
        recognizedImage.layer.masksToBounds = true;
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
        //continuouslyUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /* A forever loop to keep checking the on-phone ML model for what object is in the screen. Runs 2 times per second */
    func continuouslyUpdate() {
         if self.selectedView.isHidden == true{
        //use new thread
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            self.detect()
            self.continuouslyUpdate()
            }
        }// end if
    }

    /**
     Handles selected image
        - sends it to server
        - pauses scene view
        - triggers pop up
     */
    func selectedImageHandler(){
            //shows the selected image
            selectedView.isHidden = false
            selectedView.image = selectedImage
        
            //pauses the sceneview and hides it
            sceneView.pause(Any?.self)
            sceneView.isHidden = true
        
            //Stop ML Model from running
            // I was able to do this by adding this: "if self.selectedView.isHidden == true" in func continuouslyUpdate()
        
            //Send to AWS server
            sendImageToAWS(imageToSend: selectedImage!)
        
            //Trigger Pop Up
            popUpView.frame.origin.y = topOfPopUp + 250
            popUpView.isHidden = false
            UIView.animate(withDuration: 0.4, delay: 0.1, options:
                UIViewAnimationOptions.curveEaseOut, animations: {
                    self.popUpView.frame.origin.y = self.topOfPopUp
                }, completion: nil
                )

    }
    
    /**
     Handles pop up view content
     - loads response from aws into pop up view
     */
    func popUpViewContentHandler(shoe: shoe) {
        //image
        recognizedImage.image = shoe.image

        //name
        recognizedName.text = shoe.name
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
            // get the image of the shoe before running AR
            selectedImage = sceneView.snapshot()
            //display AR node near the shoe to be queried
            displayARShoe()
            }
        
    } //end detect

    /**
     When capture button is tapped, it takes the picture and writes it to the camera roll
     - Parameters:
        - sender: captureButton
     */
    @IBAction func cameraTapped(_ sender: UIButton) {
        //erase the ar shoe node so it's not save in snapshot
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
    
    /**
     When a user closes the pop up reset camera feed
     */
    @IBAction func closePopUp(_ sender: UIButton) {
        //removes the selected image
        selectedView.isHidden = true
        
        //hide pop up view
        popUpView.isHidden = true
        
        //resumes the sceneview
        sceneView.isHidden = false
        sceneView.play(Any?.self)
      //  self.continuouslyUpdate()
    }
    
    
    
    //method to add AR shoe node near recognized shoe
    func displayARShoe() -> Void {
        //erase the old shoe nodes so we only display one at a time
        eraseARNodes(nodeNameToErase: "shoe_node", sceneView: self.sceneView)
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
        shoe_3d_node?.name = "shoe_node"
        shoe_3d_node?.position = currentPositionOfCamera
        self.sceneView.scene.rootNode.addChildNode(shoe_3d_node!)
        let rotateshoeNode = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 2)
        let forevershoeNode = SCNAction.repeat(rotateshoeNode, count:1)
        //run AR
        shoe_3d_node?.runAction(forevershoeNode)
        //make sure the AR has run then selected handler
        sleep(2)
        DispatchQueue.main.async {
            self.selectedImageHandler()
        }
        //remove shoe from view after done running
        shoe_3d_node?.removeFromParentNode()
        
    }
    
    
    func sendImageToAWS(imageToSend: UIImage){
            //temporarily calling pop up handler here but delete when we get success call back
        let shoe1 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy PowerPhase",
                         desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                         price: 120)
        self.popUpViewContentHandler(shoe: shoe1)
        // Set up the URL request
        let AWS_get_endpoint: String = "https://3wpql46dsk.execute-api.us-east-1.amazonaws.com/prod/Recommend_Function/"
        guard let url = URL(string: AWS_get_endpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling endpoint")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
          //      guard let AWS_received_data = try JSONSerialization.jsonObject(with: responseData, options: [])
           //         as? [String: Any] else {
            //            print("did not receive data from AWS")
               //         return
               // }
                
                let convertedString = String(data: responseData, encoding: String.Encoding.utf8)
                // let's just print it to prove we can access it
                print("The data from AWS is: " + convertedString!)
                //update name of shoe to show returned string
                 DispatchQueue.main.async {
                self.recognizedName.text = convertedString!
                }
              //  self.popUpViewContentHandler(shoe: shoe1)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
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




