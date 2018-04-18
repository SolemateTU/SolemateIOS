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
     //  var selected:shoe!
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
            
//            //Add the edit button to the navigation bar
//            navigationItem.rightBarButtonItem = editButtonItem
           
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
                          price: 120, url:"google.com/")
         let shoe2 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy Powerphase",
                             desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                             price: 120, url:"google.com/")
        let shoe3 = shoe(image: #imageLiteral(resourceName: "Powerphases"), name: "Yeezy Powerphase",
                             desc: "The shoe is highlighted by its all-black leather upper, then featuring gold Calabasas branding alongside, in addition to adidas tagging in green and red. Tonal laces accompany to round out the design details.",
                             price: 120, url:"google.com/")
           shoeList += [shoe1,shoe2,shoe3]
            saveShoes()
            
        }
    
        //Send shoe object selected to detail vew controller
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            super.prepare(for: segue, sender: sender)
            
            // Configure the destination view controller when
            if let selectedShoe = sender as? shoeCell{
                
                
                guard let detailsViewController = segue.destination as? shoeDetailsViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedShoe) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                let selected = shoeList[indexPath.row]
                detailsViewController.selectedShoe = selected
            }
            
        }
    
        //MARK: Actions
    
        /**
        Allows Camera view to add new shoes to the list
        - Parameters:
            - shoe: Shoe that was recognized
        */
       public func addShoe(shoe:shoe){
        if let savedShoes = loadShoes() {
            shoeList += savedShoes

        print("shoeList.count ", shoeList.count)
        for i in 0...shoeList.count-1{
            if(shoeList[i].name == shoe.name){
                break
            }else if (i == shoeList.count-1){
                shoeList.append(shoe)
                saveShoes()
            }
        }
        }else{
            shoeList.append(shoe)
        }
        
    }
    /**
     Allows Detail view to check whether the recommended shoe id is already saved locally
     - Parameters:
        - listToCheck: List of shoe IDs to be checked
     - Returns: [shoe]: a list of shoes that we have saved corresponding to the IDs we checked
     */
    public func checkPersistentStorage(listToCheck:[String])-> [shoe?]{
        var listToReturn: [shoe?] = [nil,nil,nil]
 
        if let savedShoes = loadShoes() {
            shoeList += savedShoes
            for i in 0..<listToCheck.count{
                let shoeName = listToCheck[i].replacingOccurrences(of: "_", with: " ")
                for j in 0..<shoeList.count{
                    if (shoeList[j].name == shoeName){
                        listToReturn[i] = shoeList[j]
                    }
                    
                }//end inner for
            }//end outer for
        }//end if
        return listToReturn
    }
    
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
