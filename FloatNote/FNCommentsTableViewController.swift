//
//  FNCommentsViewController.swift
//  FloatNote
//
//  Created by Jared Downing on 10/14/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import UIKit

class FNCommentsTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewFooter: UIView!
    @IBOutlet weak var tableViewHeader: UIView!
    @IBOutlet weak var votesTextLabel: UILabel!
    @IBOutlet weak var projectTextLabel: UILabel!
    @IBOutlet weak var timeTextLabel: UILabel!
    @IBOutlet weak var downvoteButton: UIImageView!
    @IBOutlet weak var upvoteButton: UIImageView!
    @IBOutlet weak var noCommentsLabel: UILabel!
    
    var pathToFollow: String = ""
    var projectText: String = ""
    var timeText: String = ""
    var votesNumber: String = ""
    
    var comments = [Comment]()
    var commentsLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpConfig()
        setUpButtons()
        setUpComments()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        
        super.willMove(toParentViewController: self.parent)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func setUpConfig() {
        
        self.title = "Comments"
        tableView.tableHeaderView = tableViewHeader
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        projectTextLabel.text = projectText
        votesTextLabel.text = votesNumber
        
        setupTime()
        
        if !thisUser.has(seen: thisNote!.uuid) {
            self.navigationController?.toolbar.items?[1].title = "You must be close to this note to comment."
        }
        
    }
    
    func setupTime() {
        
        let currentDate = Date()
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let convertedNoteDate = formatter.date(from: timeText) {
            let diff = currentDate.offset(from: convertedNoteDate)
            timeTextLabel.text = String(describing: diff)
        }

    }
    
    func setUpButtons() {
        
        let upvoteTapGesture = UITapGestureRecognizer(target: self, action: #selector(upvotePressed))
        let downvoteTapGesture = UITapGestureRecognizer(target: self, action: #selector(downvotePressed))
        
        upvoteButton.addGestureRecognizer(upvoteTapGesture)
        downvoteButton.addGestureRecognizer(downvoteTapGesture)
        
        upvoteButton.isUserInteractionEnabled = true
        downvoteButton.isUserInteractionEnabled = true
        
        upvoteButton.image = upvoteButton.image?.imageWithColor(color1: UIColor.lightGray)
        downvoteButton.image = downvoteButton.image?.imageWithColor(color1: UIColor.lightGray)
       
        
        
    }
    func setUpComments() {
        
        loadCommentsWith(path: pathToFollow)
        
    }
    
    func onClickedToolbeltbutton() {
        
    }
    
    
    
    @IBAction func unwindToCommentsList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? FNNewCommentViewController {
            
            if let comment = sourceViewController.comment {
                
                thisComment = comment
                
                if thisComment!.text != "" {
                    
                    comments.append(comment)
                    tableView.reloadData()
                    createNew(comment: comment)
                    
                }
            }
        }
    }
    
    
    func upvotePressed() {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.upvoteButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            
            
        }, completion: { finished in
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.upvoteButton.transform = CGAffineTransform.identity
                
                
            }, completion: { finished in
                
                
                
            })
            
            
        })
        
        if let uuid = thisNote?.uuid  {
            if thisUser.canUpvote(uuid: uuid) {
                
                if thisUser.hasInteracted(with: uuid) {
                    updateVoteLabels(by: 1)
                }
                else {
                    updateVoteLabels(by: 2)
                }
                
                thisUser.updateNote(uuid: uuid, canUpvote: false, canDownvote: true)
            }
        }
        
        saveNotes()
        
        
    }
    
    func downvotePressed() {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.downvoteButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            
            
        }, completion: { finished in
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.downvoteButton.transform = CGAffineTransform.identity
                
                
            }, completion: { finished in
                
                
                
            })
            
            
        })
        
        if let uuid = thisNote?.uuid {
            
            if thisUser.canDownvote(uuid: uuid) {
                
                if thisUser.hasInteracted(with: uuid) {
                    updateVoteLabels(by: -1)
                }
                else {
                    updateVoteLabels(by: -2)
                }
                
                thisUser.updateNote(uuid: uuid, canUpvote: true, canDownvote: false)
            }
        }
        
        saveNotes()
    }
    
    func updateVoteLabels(by value: Int) {
        
        votesTextLabel.text = String(Int(votesTextLabel.text!)! + value)
        
        if value > 0 {
            
            upvoteButton.image = upvoteButton.image?.imageWithColor(color1: UIColor.purple)
            downvoteButton.image = downvoteButton.image?.imageWithColor(color1: UIColor.lightGray)
            
            thisNote!.upvotes = String(Int(thisNote!.upvotes)! + 1)
            
        }
        else {
            
            upvoteButton.image = upvoteButton.image?.imageWithColor(color1: UIColor.lightGray)
            downvoteButton.image = downvoteButton.image?.imageWithColor(color1: UIColor.purple)
            
            thisNote!.downvotes = String(Int(thisNote!.downvotes)! + 1)
            
        }
        
        let noteUpdates = [ "/base/notes/\(thisNote!.uuid)" : thisNote!.toAny() ]
        let userUpdates = [ "\(userPath)/votes/\(thisNote!.uuid)" : thisNote!.toAny()]
        
        firebaseReference.updateChildValues(noteUpdates)
        firebaseReference.updateChildValues(userUpdates)
        
    }
    
    func saveNotes() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(thisUser.viewedNotes, toFile: NoteCached.ArchiveURL.path)
        
        if !isSuccessfulSave {
            
            print("Failed to save notes...")
            
        }
        
    }
    
}

// MARK: UITableViewController
extension FNCommentsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "FNCommentsTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as! FNCommentsTableViewCell
        
        
        let displayText = comments[indexPath.row].text
        let timeDisplayText = comments[indexPath.row].time
        
        let currentDate = Date()
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        //TODO: CHANGE TO GET FROM TIME DISPLAY TEXT
        let convertedNoteDate = formatter.date(from: "2016-11-13 14:48:04 +0000")
        let diff = currentDate.offset(from: convertedNoteDate!)
        
        
        cell.commentsTextLabel.text = displayText
        cell.timeTextLabel.text = String(describing: diff)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentsTableViewController = storyboard.instantiateViewController(withIdentifier: "FNCommentsTableViewController") as! FNCommentsTableViewController
        
        commentsTableViewController.pathToFollow = thisNote!.uuid
        commentsTableViewController.projectText = thisNote!.text
        commentsTableViewController.votesNumber = thisNote!.downvotes
        commentsTableViewController.timeText = thisNote!.time
        
        print(thisNote!.toAny())
        
        self.navigationController?.pushViewController(commentsTableViewController, animated: true)
        
    }
    
    
}

// MARK: Database
extension FNCommentsTableViewController {
    
    func createNew(comment: Comment) {
        
        self.noCommentsLabel.alpha = 0
        
        let commentsKey = firebaseReference.child("comments").childByAutoId().key
        thisComment!.uuid = commentsKey
        thisUser.karma = String(Int((thisUser.karma))! + 5)
        
        let comment = Comment(uuid: commentsKey, user: thisUser.uuid, time: thisComment!.time, reports: "0", text: thisComment!.text)
        
        let noteUpdates = [ "/base/comments/\(thisNote!.uuid)/\(commentsKey)": comment!.toAny() ]
        let userUpdates = ["\(userPath)/comments/\(thisNote!.uuid)": thisNote!.toAny(), "\(userPath)/stats/" : thisUser.toAny()]

        
        firebaseReference.updateChildValues(noteUpdates)
        firebaseReference.updateChildValues(userUpdates)
        
    }
    
    func loadCommentsWith(path: String) {
        
        firebaseReference.child("base").child("comments").child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value != nil {
                
                if (snapshot.value as? NSNull?) != nil {
                    
                    // Null in database
                    
                }
                else {
                    
                    if let commentJSONValues = snapshot.value as! [String: NSDictionary]? {
                        
                        for comment in commentJSONValues {
                            
                            let commentValues = comment.1
                            
                            let reports = commentValues["reports"] as! String
                            let text = commentValues["text"] as! String
                            let time = commentValues["time"] as! String
                            let user = commentValues["user"] as! String
                            let uuid = commentValues["uuid"] as! String
                            
                            if let commentToAdd = Comment(uuid: uuid, user: user, time: time, reports: reports, text: text) {
                                
                                if commentToAdd.text != "init" {
                                    self.comments.append(commentToAdd)
                                }
                                
                                
                                DispatchQueue.main.async { () -> Void in
                                    
                                    if self.comments.count > 0 {
                                        
                                        // Set alpha for no internet to 0
                                        self.noCommentsLabel.alpha = 0
                                        
                                        self.tableView.reloadData()
                                        
                                    }
                                    else {
                                        self.noCommentsLabel.alpha = 1
                                        // 0 Notes in database
                                        
                                    }
                                    
                                    self.commentsLoaded = true
                                    
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
            
            
        }) { (error) in
            
            print(error.localizedDescription)
        }
        
    }
    
}
