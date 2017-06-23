//
//  FNMyActionsTableViewController.swift
//  FloatNote
//
//  Created by Jared Downing on 10/14/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class FNMyActionsTableViewController: UITableViewController {
    
    var notesLoaded: Bool = false
    var notes = [Note]()
    var pathToFollow = "notes"
    var fields = [String]()
    
    @IBOutlet weak var tableViewFooter: UIView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpConfig()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        self.title = pathToFollow.capitalized
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setUpConfig() {
        
        loadUserInfoWith(path: pathToFollow)
        tableView.tableFooterView = tableViewFooter
        
    }
    
    
}

// MARK: Table View construction
extension FNMyActionsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FNMyActionsTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as! FNMyActionsTableViewCell
        
        if Int(notes[indexPath.row].upvotes) != nil {
            cell.noteTextLabel.text = notes[indexPath.row].text
            cell.votesLabel.text = String(Int(notes[indexPath.row].upvotes)! - Int(notes[indexPath.row].downvotes)!)
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentsTableViewController = storyboard.instantiateViewController(withIdentifier: "FNCommentsTableViewController") as! FNCommentsTableViewController
        
        commentsTableViewController.pathToFollow =  notes[indexPath.row].uuid
        commentsTableViewController.projectText =  notes[indexPath.row].text
        commentsTableViewController.votesNumber =  String(Int(notes[indexPath.row].upvotes)! - Int(notes[indexPath.row].downvotes)!)
        commentsTableViewController.timeText =  notes[indexPath.row].time
        
        self.navigationController?.pushViewController(commentsTableViewController, animated: true)
        
        
        var s: UITabBarItem = UITabBarItem()
    }
    
}

// MARK: Load Data
extension FNMyActionsTableViewController {
    
    func loadUserInfoWith(path: String) {
        
        firebaseReference.child("base").child("users").child(thisUser.uuid).child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value != nil {
                
                if (snapshot.value as? NSNull?) != nil {
                    
                    // Null in database
                    
                }
                else {
                    
                    if let noteJSONValues = snapshot.value as! [String: NSDictionary]? {
                        
                        for note in noteJSONValues {
                            
                            let noteValues = note.1
                            
                            let time = noteValues["time"] as! String
                            let lat = noteValues["lat"] as! String
                            let long = noteValues["long"] as! String
                            let text = noteValues["text"] as! String
                            let upvotes = noteValues["upvotes"] as! String
                            let downvotes = noteValues["downvotes"] as! String
                            let reports = noteValues["reports"] as! String
                            let user = noteValues["user"] as! String
                            let comments = noteValues["comments"] as! String
                            
                            if let noteToAdd = Note(uuid: note.0, time: time, lat: lat,  long: long, text: text, upvotes: upvotes, downvotes: downvotes,  reports: reports, user: user, comments: comments) {
                                
                                if noteToAdd.text != "init" {
                                    self.notes.append(noteToAdd)
                                }
                                
                                
                                DispatchQueue.main.async { () -> Void in
                                    
                                    if self.notes.count > 0 {
                                        
                                        self.tableView.reloadData()
                                        
                                        self.emptyLabel.alpha = 0
                                        
                                    }
                                    
                                    self.notesLoaded = true
                                    
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
            
            
        }) { (error) in
            
            print(error.localizedDescription)
            
            // Failure to load notes
            
        }
        
    }
    
}
