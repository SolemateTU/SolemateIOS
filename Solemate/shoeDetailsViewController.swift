//
//  shoeDetailsViewController.swift
//  Solemate
//
//  Created by Harjap Uppal on 3/21/18.
//  Copyright © 2018 Uppalled. All rights reserved.
//

import Foundation
import UIKit

class shoeDetailsViewController: UIViewController{
    ///Shoe details to be displayed
    var shoe : shoe!
    ///Shoe Stock Image
    @IBOutlet weak var shoeImage: UIImageView!
    ///Shoe name
    @IBOutlet weak var shoeName: UILabel!
    ///Shoe price
    @IBOutlet weak var shoePrice: UILabel!
    ///Shoe description
    @IBOutlet weak var shoeDescription: UILabel!
    ///Table view for similar shoes
    @IBOutlet weak var similarShoesTableView: UITableView!
    ///Navigation title
    @IBOutlet weak var navTitle: UINavigationItem!
    override func viewDidLoad() {
        //if shoe is not empty
        if shoe != nil {
            navTitle.title = shoe.name
            loadShoeDetailsHandler(shoe: shoe)
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
        //price
        shoePrice.text = String(shoe.price)
    }
    
}
