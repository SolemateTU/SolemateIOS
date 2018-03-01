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
        public var shoeList = [shoe]()
        var selected:shoe!
        override func numberOfSections(in tableView: UITableView) -> Int{
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return shoeList.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cellIdentifier = "shoeCell"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? shoeCell
            
            let shoe = shoeList[indexPath.row]
          

            return cell!
        }
        
        // Override to edit the list of shoes
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the row from the data source
                shoeList.remove(at: indexPath.row)
              //  saveShoes()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            
        //    navigationItem.leftBarButtonItem = editButtonItem
           /*
            // Load any saved shoes, otherwise load sample shoes
            if let savedShoes = loadShoes() {
                shoeList += savedShoes
            }
            else {
                // Load the sample shoes
                loadSample()
            }*/
          
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        //Sample shoes
        private func loadSample() {
        /* let shoe1 =
            let shoe2 =
            let shoe3 =
            shoeList += [shoe1,shoe2,shoe3]*/
            
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
        /*
        private func saveShoes() {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(shoeList, toFile: shoe.ArchiveURL.path)
            if isSuccessfulSave {
                os_log("Shoes successfully saved.", log: OSLog.default, type: .debug)
            } else {
                os_log("Failed to save shoes...", log: OSLog.default, type: .error)
            }
        }
        private func loadShoes() -> [shoe]?  {
            return NSKeyedUnarchiver.unarchiveObject(withFile: shoeList.ArchiveURL.path) as? [shoe]
        }*/


    
}
