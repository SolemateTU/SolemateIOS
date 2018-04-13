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

class shoeDetailsViewController: UIViewController, UITableViewDataSource{
    ///Shoe details to be displayed
    var selectedShoe : shoe!
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
     var similarShoeList = [shoe]()
    


    override func viewDidLoad() {
        //if shoe is not empty
        if selectedShoe != nil {
            navTitle.title = selectedShoe.name
            loadShoeDetailsHandler(shoe: selectedShoe)
            loadSample()
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
       similarShoesTableView.reloadData()
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
        shoePrice.text = "$\(Int(shoe.price))"
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
            detailsViewController.selectedShoe = selected
            print(selected)
        }
        
    }
    
    /**
     Sample shoes preloaded on application
     */
    private func loadSample() {
        let shoe1 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy Powerphase",
                         desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                         price: 120)
        let shoe2 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy Powerphase",
                         desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                         price: 120)
        let shoe3 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy Powerphase",
                         desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                         price: 120)
        similarShoeList += [shoe1,shoe2,shoe3]

    }
    
}
