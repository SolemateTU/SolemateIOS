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

class shoe: NSObject{
    //add extension for NSCoding
    ///Shoe stock image
    var  image: UIImage
    ///Shoe name
    var name:String
    ///Shoe description
    var desc: String
    ///Shoe price
    var price: Double
 
     init(image: UIImage, name: String, desc: String, price:Double) {
        self.image = image
        self.name =  name
        self.desc = desc
        self.price = price
    }
    
    /*
     func encode(with aCoder: NSCoder) {
     <#code#>
     }
     
     required init?(coder aDecoder: NSCoder) {
     <#code#>
     }
     
     func encode(with aCoder: NSCoder) {
     <#code#>
     }
     
     */
}
