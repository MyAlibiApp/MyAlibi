//
//  SecondViewController.swift
//  FloatNote
//
//  Created by Jared Downing on 10/11/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import UIKit
import Foundation

class FNHomeTableViewController: UITableViewController {
    
    var fields = [String]()
    
    @IBOutlet weak var tableViewFooter: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpConfig()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpConfig() {
        
        fields.append("My Notes")
        fields.append("My Comments")
        fields.append("My Votes")
        
        tableView.tableFooterView = tableViewFooter
        
        self.tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.3)
        
    }
    
    
}

// MARK: Table View
extension FNHomeTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FNHomeTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as! FNHomeTableViewCell
        
        let displayText = fields[indexPath.row]
        
        cell.rowLabel.text = displayText
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let myActionsTableViewController = storyboard.instantiateViewController(withIdentifier: "FNMyActionsTableViewController") as! FNMyActionsTableViewController
        
        
        if fields[indexPath.row] == "My Notes" {
            
            myActionsTableViewController.title = fields[indexPath.row]
            myActionsTableViewController.pathToFollow = "notes"
            
        }
        else if fields[indexPath.row] == "My Comments" {
            
            myActionsTableViewController.title = fields[indexPath.row]
            myActionsTableViewController.pathToFollow = "comments"
            
        }
        else if fields[indexPath.row] == "My Votes" {
            
            myActionsTableViewController.title = fields[indexPath.row]
            myActionsTableViewController.pathToFollow = "votes"
            
        }
        
        self.navigationController?.pushViewController(myActionsTableViewController, animated: true)
        
        
    }
    
}
