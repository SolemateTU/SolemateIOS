//
//  shoeCell.swift
//  Solemate
//
//  Created by Harjap Uppal on 2/28/18.
//  Copyright © 2018 Uppalled. All rights reserved.
//
import UIKit
import Foundation
class shoeCell: UITableViewCell {
    ///Shoe image, table view
    @IBOutlet weak var shoeImage: UIImageView!
    ///Shoe name, table view
    @IBOutlet weak var shoeName: UILabel!
    ///Shoe description, table view
    @IBOutlet weak var shoeDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //shoeImage layout
        shoeImage.layer.cornerRadius = 35
        shoeImage.layer.borderWidth = 1;
        shoeImage.layer.borderColor = UIColor.lightGray.cgColor
        shoeImage.layer.masksToBounds = true;
    
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
}
