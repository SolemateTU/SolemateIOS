//
//  shoeDetailsViewController.swift
//  Solemate
//
//  Created by Harjap Uppal on 3/21/18.
//  Copyright © 2018 Uppalled. All rights reserved.
//

import Foundation
import UIKit
import os.log


struct similarShoeToSendStruct: Codable {
    let shoeID: String
}

class shoeDetailsViewController: UIViewController, UITableViewDataSource{
    
    @IBOutlet weak var scrollView: UIScrollView!
    ///Shoe details to be displayed
    var selectedShoe : shoe!
    ///Shoe Stock Image
    @IBOutlet weak var shoeImage: UIImageView!
    ///Shoe name
    @IBOutlet weak var shoeName: UILabel!
    ///Shoe price
    @IBOutlet weak var shoePrice: UIButton!
    ///Shoe description
    @IBOutlet weak var shoeDescription: UILabel!
    ///Table view for similar shoes
    @IBOutlet weak var similarShoesTableView: UITableView!
    ///Navigation title
    @IBOutlet weak var navTitle: UINavigationItem!
     var similarShoeList = [shoe]()
    var returnedSimilarShoeList : [String]!
    override func viewDidLoad() {
        //if shoe is not empty
        if selectedShoe != nil {
            navTitle.title = selectedShoe.name
            loadShoeDetailsHandler(shoe: selectedShoe)
         //   loadSample()
            recommendationAPICall(imageToSend: selectedShoe.image)
            similarShoesTableView.dataSource = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func numberOfSections(in similarShoesTableView: UITableView) -> Int{
        return 1
    }
    
    func tableView (_ similarShoesTableView : UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarShoeList.count
    }
    
    func tableView( _ similarShoesTableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///Storyboard cell identifier
        let cellIdentifier = "shoeCell"
        
        ///Local refrence to the reusable cell view
        let cell = similarShoesTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? shoeCell
        
        let shoe = similarShoeList[indexPath.row]
        cell?.shoeImage.image = shoe.image
        cell?.shoeName.text = shoe.name
        cell?.shoeDescription.text = shoe.desc
        return cell!
    }

    
    /**
     Handles displaying details of shoes in UI
     */
    func loadShoeDetailsHandler(shoe: shoe) {
        //image
        shoeImage.image = shoe.image
        //name
        shoeName.text = shoe.name
        //description
        shoeDescription.text = shoe.desc
        shoeDescription.sizeToFit()
        //price
        let lowestPrice = "$\(Int(shoe.price))"
//        shoePrice.setAttributedTitle(lowestPrice, for: .normal)
        if let attributedTitle = shoePrice.attributedTitle(for: .normal) {
            let mutableAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
            mutableAttributedTitle.replaceCharacters(in: NSMakeRange(0, mutableAttributedTitle.length), with: lowestPrice)
            shoePrice.setAttributedTitle(mutableAttributedTitle, for: .normal)
        }
    }
    
    @IBAction func shoePriceLink(_ sender: UIButton) {
        if let url = URL(string: selectedShoe.url){
            UIApplication.shared.openURL(url)
        }
    }
    //Send shoe object selected to detail vew controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller when
        if let selectedShoe = sender as? shoeCell{
            
            
            guard let detailsViewController = segue.destination as? shoeDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = similarShoesTableView.indexPath(for: selectedShoe) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selected = similarShoeList[indexPath.row]
            solematesViewController().addShoe(shoe: selected)
            detailsViewController.selectedShoe = selected
        }
        
    }
    /**
     First details AWS Request, sends stock Image to recommendation Function, once it gets a response it calls calls second AWS Function 3 times for each recommended shoe
     - Parameters:
     - imageToSend: Image to convert and send
     */
    func recommendationAPICall(imageToSend:UIImage)  {
        //compress image before sending, as there is a limit.
        let  compression:CGFloat = 0.9;
        //convert UIimage to base64
        let imageData: NSData = UIImageJPEGRepresentation(imageToSend, compression)! as NSData
        
        let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        // Set up the URL request
        let AWS_get_endpoint: String = "http://eb-rec-flask-dev.us-east-1.elasticbeanstalk.com"
        guard let url = URL(string: AWS_get_endpoint) else {
            print("Error: cannot create URL")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        do {
            let jsonObject: [String: Any] = ["img": base64String]
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonObject)
            
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        //  print(request.value(forHTTPHeaderField: "Content-Type"))
        let task = session.dataTask(with: request) {
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
            do {
                //Debugging response
                let str = String(data: responseData, encoding: .utf8)
                print(str)
                if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                    var shoe1 =  json["shoeID-1"]  as? String,
                    var shoe2 =  json["shoeID-2"]  as? String,
                    var  shoe3 =  json["shoeID-3"]  as? String
                {
            
                    //remove stock from ID
                    shoe1 =  shoe1.replacingOccurrences(of: "_Stock", with: "")
                    shoe1 = shoe1.replacingOccurrences(of: "_stock", with: "")
                    shoe2 =  shoe2.replacingOccurrences(of: "_Stock", with: "")
                    shoe2 = shoe2.replacingOccurrences(of: "_stock", with: "")
                    shoe3 =  shoe3.replacingOccurrences(of: "_Stock", with: "")
                    shoe3 = shoe3.replacingOccurrences(of: "_stock", with: "")
                    
                    ///List of recommended shoe IDs
                    let recommendedShoeIDs =  [shoe1,shoe2,shoe3]
                    ///List of recommended shoes we have in persistent storage
                    let check = solematesViewController().checkPersistentStorage(listToCheck: recommendedShoeIDs)
                    for i in 0..<check.count{
                        if (check[i] != nil){
                            self.similarShoeList.append(check[i]!)
                            DispatchQueue.main.async {
                                self.similarShoesTableView.reloadData()
                            }
                        }else{
                            self.detailsAPICall(shoeID: recommendedShoeIDs[i])
                        }
                    }
                 //   self.detailsAPICall(shoeID: shoe2)
                  //  self.detailsAPICall(shoeID: shoe3)
                    
                    //return shoeID
                }
                
            } catch let error {
                print(error.localizedDescription)
                //self.detailsAPICall(imageb64: base64String, shoeID: shoeID)
            }
        }
        task.resume()
        
    }
    
    /**
     Details Second AWS call, sends identified shoe id's and image for the details of the identified shoe
     - Parameters:
     - shoeID: Identified shoe
     */
    func detailsAPICall(shoeID: String){
        let shoeIDToSend = similarShoeToSendStruct(shoeID: shoeID)
        
        let encoder = JSONEncoder()
        //below can be removed later
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(shoeIDToSend) else {
            return
        }
        
        // Set up the Second URL request
        let AWS_get_endpoint: String = "https://3wpql46dsk.execute-api.us-east-1.amazonaws.com/prod/identification-function"
        guard let url = URL(string: AWS_get_endpoint) else {
            print("Error: cannot create URL")
            return
        }
        var request = URLRequest(url: url)
        //sending the request in JSON
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        //add json data to the request
        request.httpBody = jsonData
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: request) {
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

            // parse the result as JSON
            let decoder = JSONDecoder()
            do {
                ///shoe recieved from AWS
                let receivedShoe = try decoder.decode(receivedShoeStruct.self, from: responseData)
                ///image data decoded from base 64
                let dataDecoded = Data(base64Encoded: receivedShoe.shoeImage, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                ///UIImage from the data decoded from base 64
                let decodedImage = UIImage(data: dataDecoded)!
                //convert response price to double
                let priceDouble = Double(receivedShoe.lowestPrice.replacingOccurrences(of: "$", with: ""))
                
                ///Shoe object created with data from AWS
                let shoeDecoded = shoe(image:decodedImage , name: receivedShoe.shoeTitle,
                                       desc: receivedShoe.shoeDescription,
                                       price: priceDouble!, url:receivedShoe.url)
                self.similarShoeList.append(shoeDecoded)
                DispatchQueue.main.async {
                    //dump(self.similarShoeList)
                    ///Send shoe to popup content handler to display
              //      self.popUpViewContentHandler(shoe: shoeDecoded)
                    self.similarShoesTableView.reloadData()
                }

            } catch  {
                print("error trying to convert data to JSON")
                
                /*shoeDecoded = error
                 DispatchQueue.main.async {
                 ///Send shoe to popup content handler to display
                 self.popUpViewContentHandler(shoe: shoeDecoded)
                 }*/
                return
            }
            
        }
        task.resume()
        
    }
    
    /**
     Sample shoes preloaded on application
     */
    private func loadSample() {
        let shoe1 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy Powerphase",
                         desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                         price: 120,
                         url:"google.com/")
        let shoe2 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy Powerphase",
                         desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                         price: 120,
                         url:"google.com/")
        let shoe3 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy Powerphase",
                         desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                         price: 120,
                         url:"google.com/")
        similarShoeList += [shoe1,shoe2,shoe3]

    }
    
}

