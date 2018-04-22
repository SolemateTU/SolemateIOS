//
//  solematesViewController.swift
//  Solemate
//
//  Created by Bill Moriarty
//  Copyright © 2018 Uppalled. All rights reserved.
//

import Foundation
import UIKit

struct cellData {
    let img: UIImage?
    let message: String?
}

struct userPhotoStruct: Codable{
    var shoeImage1: String?
    var shoeImage2: String?
    var shoeImage3: String?
    var shoeImage4: String?
    var shoeImage5: String?
    var shoeImage6: String?
    var shoeImage7: String?
    var shoeImage8: String?
    var shoeImage9: String?
    var shoeImage10: String?
    var shoeImage11: String?
    var shoeImage12: String?
    var shoeImage13: String?
    var shoeImage14: String?
    var shoeImage15: String?
}

class userPhotosViewController: UITableViewController{
  
    var sampleData = [cellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserPhotosAWS(userID: "tug46894")

        sampleData = []

        self.tableView.register(customCell.self, forCellReuseIdentifier: "customUserPhotoCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "customUserPhotoCell") as! customCell
        cell.imageForCell = sampleData[indexPath.row].img
        cell.messageForCell = sampleData[indexPath.row].message
        cell.layoutSubviews()
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    call endpoint to get user photos
    func getUserPhotosAWS(userID : String)  {

        // Set up the URL request
        let AWS_get_endpoint: String = "https://3wpql46dsk.execute-api.us-east-1.amazonaws.com/prod/get-user-images"
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
            let jsonObject: [String: Any] = ["userID": userID]
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
            // parse the result as JSON
            let decoder = JSONDecoder()
            do {
                ///shoe recieved from AWS
                let receivedShoe = try decoder.decode(userPhotoStruct.self, from: responseData)
                //maybe setup a for loop for getting each image and appending to sampleData
                    ///image data decoded from base 64
                if (receivedShoe.shoeImage1 != nil){
                    let dataDecoded = Data(base64Encoded: receivedShoe.shoeImage1!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage = UIImage(data: dataDecoded)!
                    self.sampleData.append(cellData.init(img: decodedImage, message: "_"))
                }
                
                if (receivedShoe.shoeImage2 != nil){
                    let dataDecoded2 = Data(base64Encoded: receivedShoe.shoeImage2!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage2 = UIImage(data: dataDecoded2)!
                    self.sampleData.append(cellData.init(img: decodedImage2, message: "_"))
                }
                
                if  (receivedShoe.shoeImage3 != nil){
                    let dataDecoded3 = Data(base64Encoded: receivedShoe.shoeImage3!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage3 = UIImage(data: dataDecoded3)!
                    self.sampleData.append(cellData.init(img: decodedImage3, message: "_"))
                }
                if  (receivedShoe.shoeImage4 != nil){
                    let dataDecoded4 = Data(base64Encoded: receivedShoe.shoeImage4!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage4 = UIImage(data: dataDecoded4)!
                    self.sampleData.append(cellData.init(img: decodedImage4, message: "_"))
                }
                if  (receivedShoe.shoeImage5 != nil){
                    let dataDecoded5 = Data(base64Encoded: receivedShoe.shoeImage5!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage5 = UIImage(data: dataDecoded5)!
                    self.sampleData.append(cellData.init(img: decodedImage5, message: "_"))
                }
                if  (receivedShoe.shoeImage6 != nil){
                    let dataDecoded6 = Data(base64Encoded: receivedShoe.shoeImage6!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage6 = UIImage(data: dataDecoded6)!
                    self.sampleData.append(cellData.init(img: decodedImage6, message: "_"))
                }
                if  (receivedShoe.shoeImage7 != nil){
                    let dataDecoded7 = Data(base64Encoded: receivedShoe.shoeImage7!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage7 = UIImage(data: dataDecoded7)!
                    self.sampleData.append(cellData.init(img: decodedImage7, message: "_"))
                }
                if  (receivedShoe.shoeImage8 != nil){
                    let dataDecoded8 = Data(base64Encoded: receivedShoe.shoeImage8!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage8 = UIImage(data: dataDecoded8)!
                    self.sampleData.append(cellData.init(img: decodedImage8, message: "_"))
                }
                if  (receivedShoe.shoeImage9 != nil){
                    let dataDecoded9 = Data(base64Encoded: receivedShoe.shoeImage9!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage9 = UIImage(data: dataDecoded9)!
                    self.sampleData.append(cellData.init(img: decodedImage9, message: "_"))
                }
                if  (receivedShoe.shoeImage10 != nil){
                    let dataDecoded10 = Data(base64Encoded: receivedShoe.shoeImage10!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage10 = UIImage(data: dataDecoded10)!
                    self.sampleData.append(cellData.init(img: decodedImage10, message: "_"))
                }
                if  (receivedShoe.shoeImage11 != nil){
                    let dataDecoded11 = Data(base64Encoded: receivedShoe.shoeImage11!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let decodedImage11 = UIImage(data: dataDecoded11)!
                    self.sampleData.append(cellData.init(img: decodedImage11, message: "_"))
                }
                
                DispatchQueue.main.async {
                    self.tableView.layoutSubviews()
                    self.tableView.reloadData()
                }

            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
        
    }//end AWS call function
    
}//end class
