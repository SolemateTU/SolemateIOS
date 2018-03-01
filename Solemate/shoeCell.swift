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
    
    @IBOutlet weak var shoeImage: UIImageView!
    @IBOutlet weak var shoeName: UILabel!
    @IBOutlet weak var shoeDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
}
