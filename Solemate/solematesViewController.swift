//
//  solematesViewController.swift
//  Solemate
//
//  Created by Harjap Uppal on 2/28/18.
//  Copyright © 2018 Uppalled. All rights reserved.
//

import Foundation
import UIKit
import os.log

class solematesViewController: UITableViewController{
        ///List holding all the shoes
        public var shoeList = [shoe]()
    
       var selected:shoe!
        override func numberOfSections(in tableView: UITableView) -> Int{
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return shoeList.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            ///Storyboard cell identifier
            let cellIdentifier = "shoeCell"
            
            ///Local refrence to the reusable cell view
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? shoeCell
            
            let shoe = shoeList[indexPath.row]
            cell?.shoeImage.image = shoe.image
            cell?.shoeName.text = shoe.name
            cell?.shoeDescription.text = shoe.desc

            return cell!
        }
        
        // Override to edit the list of shoes
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the row from the the shoe list
                shoeList.remove(at: indexPath.row)
                
                //Save the updated list
                 saveShoes()
                
                //remove the shoe from the users view with animation
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //Add the edit button to the navigation bar
            navigationItem.rightBarButtonItem = editButtonItem
           
            // Load any saved shoes, otherwise load sample shoes
            if let savedShoes = loadShoes() {
                shoeList += savedShoes
            }
            else {
                // Load the sample shoes
                loadSample()
            }
           // loadSample()
          
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
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
           //let shoe3 =
           shoeList += [shoe1,shoe2]
            
        }
        
      /*  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            super.prepare(for: segue, sender: sender)
            
            // Configure the destination view controller only when the save button is pressed.
            if let selectedShoe = sender as? shoeCell{
                
                
                guard let viewViewController = segue.destination as? ViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedPin) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                let selected = shoeList[indexPath.row]
                solematesViewController.shoe = selected
                print(selected)
            }
            
        }*/
        
        //MARK: Navigation
   /* Use this to add recently recognized shoes from the viewController scene
     @IBAction func unwindToPinsList(sender: UIStoryboardSegue) {
            if let sourceViewController = sender.source as? ViewController, let shoe = sourceViewController.shoe {
                // Add a new task.
                let newIndexPath = IndexPath(row: shoeList.count, section: 0)
            //get more info about savedShoe from database
            //let savedShoe = shoe()
                shoe.append(shoe)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                saveShoes()
            }
            
        }*/
        
        
        
        //MARK: Actions
    
        /**
        Saves the shoes currently in the shoeList
        */
        private func saveShoes() {
            
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(shoeList, toFile: shoe.ArchiveURL.path)
            
            if isSuccessfulSave {
                os_log("Shoes successfully saved.", log: OSLog.default, type: .debug)
            } else {
                os_log("Failed to save shoes...", log: OSLog.default, type: .error)
            }
            
        }
    
      /**
      Loads the saved shoes from the archive
      */
        private func loadShoes() -> [shoe]?  {
            
            return NSKeyedUnarchiver.unarchiveObject(withFile: shoe.ArchiveURL.path) as? [shoe]
            
        }


    
}
