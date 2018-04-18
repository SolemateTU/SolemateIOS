//
//  shoe.swift
//  Solemate
//
//  Created by Harjap Uppal on 2/28/18.
//  Copyright © 2018 Uppalled. All rights reserved.
//

import Foundation
import UIKit
import os.log

class shoe: NSObject, NSCoding{
    
    //MARK: Properties
    
    ///Shoe stock image
    var  image: UIImage
    ///Shoe name
    var name:String
    ///Shoe description
    var desc: String
    ///Shoe price
    var price: Double
    ///Website to buy at lowest price
    var url: String
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("shoeList")
    
    //MARK: Types
    
    ///Keys
    struct PropertyKey {
        static let image = "image"
        static let name = "name"
        static let desc = "desc"
        static let price = "price"
        static let url = "url"
    }
    
    
    init(image: UIImage, name: String, desc: String, price:Double, url:String) {
        self.image = image
        self.name =  name
        self.desc = desc
        self.price = price
        self.url = url
    }
    
    
     func encode(with aCoder: NSCoder) {
        
        aCoder.encode(image, forKey: PropertyKey.image)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(desc, forKey: PropertyKey.desc)
        aCoder.encode(price, forKey: PropertyKey.price)
        aCoder.encode(url, forKey: PropertyKey.url)
     }
     
    required convenience init?(coder aDecoder: NSCoder) {

        guard let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage else {
            os_log("Unable to decode the image for a shoe object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a shoe object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let desc = aDecoder.decodeObject(forKey: PropertyKey.desc) as? String else {
            os_log("Unable to decode the description for a shoe object.", log: OSLog.default, type: .debug)
            return nil
        }
        
       guard let price = aDecoder.decodeDouble(forKey: PropertyKey.price) as Optional else {
            os_log("Unable to decode the price for a shoe object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let url = aDecoder.decodeObject(forKey: PropertyKey.url) as? String else {
            os_log("Unable to decode the url for a shoe object.", log: OSLog.default, type: .debug)
            return nil
        }
        //initialize as shoe object with these variables
        self.init(image: image, name: name, desc: desc, price: price, url: url)
        
    }
  
     
 
}
