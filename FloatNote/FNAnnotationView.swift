//
//  FNAnnotationView.swift
//  FloatNote
//
//  Created by Jared Downing on 10/04/16
//  Copyright (c) 2015 Jared Downing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import HDAugmentedReality

open class FNAnnotationView: ARAnnotationView
{
    open var titleLabel: UILabel?
    open var interactLabel: UILabel?
    open var votesLabel: UILabel?
    open var distanceLabel: UILabel?
    
    open var upvoteButton: UIButton?
    open var downvoteButton: UIButton?
    
    open var numberOfVotes: Int?
    
    var uuid: String = ""
    var newFrame: CGRect!

    override open func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        if self.titleLabel == nil
        {
            self.loadUi()
        }
    }
    
    func loadUi()
    {
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 25.0)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.shadowColor = UIColor.black
        label.shadowOffset = CGSize(width:0,height:2)
        label.layer.masksToBounds = false
        label.layer.shadowRadius = 5
        self.addSubview(label)
        self.titleLabel = label
        
        self.interactLabel?.removeFromSuperview()
        let label2 = UILabel()
        label2.font = UIFont.systemFont(ofSize: 18)
        label2.numberOfLines = 0
        label2.backgroundColor = UIColor.clear
        label2.textColor = UIColor(red: 137.0/255, green: 42.0/255, blue: 214.0/255, alpha: 1)
        label2.textAlignment = .center
        self.addSubview(label2)
        self.interactLabel = label2
        
        self.votesLabel?.removeFromSuperview()
        let label3 = UILabel()
        label3.numberOfLines = 0
        label3.backgroundColor = UIColor.clear
        label3.textColor = UIColor.gray
        label3.textAlignment = .center
        label3.font = UIFont(name: "Helvetica-Bold", size: 30.0)
        label3.numberOfLines = 0
        label3.backgroundColor = UIColor.clear
        label3.textColor = UIColor.init(red: 137/255.0, green: 42/255.0, blue: 214/255.0, alpha: 1)
        label3.textAlignment = .center
        label3.shadowColor = UIColor.black
        label3.shadowOffset = CGSize(width: 0, height: 1)
        
        self.addSubview(label3)
        self.votesLabel = label3
        
        self.distanceLabel?.removeFromSuperview()
        let label4 = UILabel()
        label4.font = UIFont(name: "Helvetica-Bold", size: 20.0)
        label4.numberOfLines = 0
        label4.backgroundColor = UIColor.clear
        label4.textColor = UIColor.init(red: 137/255.0, green: 42/255.0, blue: 214/255.0, alpha: 1)
        label4.textAlignment = .center
        label4.shadowColor = UIColor.black
        label4.shadowOffset = CGSize(width: 0, height: 1)
        
        self.addSubview(label4)
        self.distanceLabel = label4
        
        self.upvoteButton?.removeFromSuperview()
        upvoteButton = UIButton()
        upvoteButton?.isUserInteractionEnabled = true
        upvoteButton?.isEnabled = true
        
        if let annotation = self.annotation {
            
            if let note = Note(uuid: annotation.uuid, time: annotation.time, lat: annotation.lat, long: annotation.lon, text: annotation.title!, upvotes: annotation.upvotes, downvotes: annotation.downvotes, reports: annotation.reports, user: annotation.user, comments: annotation.comments) {
                
                if !thisUser.canUpvote(uuid: note.uuid) && thisUser.canDownvote(uuid: note.uuid) {
                    
                    upvoteButton?.setImage(UIImage(named:"up-arrow")?.imageWithColor(color1: UIColor.init(red: 137/255.0, green: 42/255.0, blue: 214/255.0, alpha: 1)), for: .normal)
                }
                else {
                    
                    upvoteButton?.setImage(UIImage(named:"up-arrow")?.imageWithColor(color1: UIColor.white), for: .normal)
                }
            }
        }
        else {
            
            upvoteButton?.setImage(UIImage(named:"up-arrow")?.imageWithColor(color1: UIColor.white), for: .normal)
        }
        
        
        upvoteButton?.layer.shadowColor = UIColor.black.cgColor
        upvoteButton?.layer.shadowOffset = CGSize(width: 0,height: 3)
        upvoteButton?.layer.shadowRadius = 2
        upvoteButton?.layer.masksToBounds = true
        upvoteButton?.layer.shadowOpacity = 1
        
        
        let upvoteTapGsture = UITapGestureRecognizer(target: self, action: #selector(FNAnnotationView.upvoteTapGesture))
        
        upvoteButton?.addGestureRecognizer(upvoteTapGsture)
        self.addSubview(upvoteButton!)
        
        
        self.downvoteButton?.removeFromSuperview()
        let button2 = UIButton()
        button2.isUserInteractionEnabled = true
        //button2.setImage(UIImage(named:"down-arrow")?.imageWithColor(color1: UIColor.white), for: .normal)
        
        if let annotation = self.annotation {
            
            if let note = Note(uuid: annotation.uuid, time: annotation.time, lat: annotation.lat, long: annotation.lon, text: annotation.title!, upvotes: annotation.upvotes, downvotes: annotation.downvotes, reports: annotation.reports, user: annotation.user, comments: annotation.comments) {
                
                if thisUser.canUpvote(uuid: note.uuid) && !thisUser.canDownvote(uuid: note.uuid) {
                    
                    button2.setImage(UIImage(named:"down-arrow")?.imageWithColor(color1: UIColor.init(red: 137/255.0, green: 42/255.0, blue: 214/255.0, alpha: 1)), for: .normal)
                }
                else {
                    
                    button2.setImage(UIImage(named:"down-arrow")?.imageWithColor(color1: UIColor.white), for: .normal)
                }
            }
        }
        else {
            
            button2.setImage(UIImage(named:"down-arrow")?.imageWithColor(color1: UIColor.white), for: .normal)
        }
        
        button2.layer.shadowColor = UIColor.black.cgColor
        button2.layer.shadowOffset = CGSize(width: 0,height: 2)
        button2.layer.shadowRadius = 3
        button2.layer.masksToBounds = true
        button2.layer.shadowOpacity = 1
        
        let downvoteTapGsture = UITapGestureRecognizer(target: self, action: #selector(FNAnnotationView.downvoteTapGesture))
        button2.addGestureRecognizer(downvoteTapGsture)
        
        self.addSubview(button2)
        downvoteButton = button2
        
        numberOfVotes = 0
        
        self.backgroundColor = UIColor.clear
        
        let commentTapGesture = UITapGestureRecognizer(target: self, action: #selector(FNAnnotationView.tapGesture))
        self.addGestureRecognizer(commentTapGesture)
        
        if self.annotation != nil {
            self.bindUi()
        }
    }
    
    func layoutUi()
    {
        self.interactLabel?.frame = CGRect(x: 0, y: self.frame.size.height / 2 - 20, width: self.frame.size.width, height: self.frame.size.height);
        self.titleLabel?.frame = CGRect(x: 25, y: 0, width: self.frame.size.width - 100, height: self.frame.size.height);
        
        self.votesLabel?.frame = CGRect(x: self.frame.size.width - 55, y: 80, width: 60, height: 30)
        
         self.distanceLabel?.frame = CGRect(x: -25, y: -self.frame.size.height / 2 + 20, width: self.frame.size.width, height: self.frame.size.height);
        
        self.upvoteButton?.frame = CGRect(x: self.frame.size.width - 40, y: 40, width: 30, height: 30)
        self.downvoteButton?.frame = CGRect(x: self.frame.size.width - 40, y: 120, width: 30, height: 30)
        
    }
    
    override open func bindUi()
    {
        if let annotation = self.annotation, let title = annotation.title, let upvotes = annotation.upvotes, let downvotes = annotation.downvotes, let uuid = annotation.uuid
        {
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1fkm", annotation.distanceFromUser / 1000) : String(format:"%.0fm", annotation.distanceFromUser)
            
            numberOfVotes = Int(upvotes)! - Int(downvotes)!
            
            self.titleLabel?.text = title
            self.votesLabel?.text = "\(numberOfVotes!)"
            self.distanceLabel?.text = "\(distance)"
            self.uuid = uuid
        }
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    open func upvoteTapGesture() {
        
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.upvoteButton?.transform = CGAffineTransform(scaleX: 2, y: 2)
            
            
        }, completion: { finished in
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.upvoteButton?.transform = CGAffineTransform.identity
                
            }, completion: nil)
        })
        
        if let annotation = self.annotation {
            
            let note = Note(uuid: annotation.uuid, time: annotation.time, lat: annotation.lat, long: annotation.lon, text: annotation.title!, upvotes: annotation.upvotes, downvotes: annotation.downvotes, reports: annotation.reports, user: annotation.user, comments: annotation.comments)!
            
            if thisUser.canUpvote(uuid: note.uuid) {
                
                if thisUser.hasInteracted(with: note.uuid) {
                    
                    self.updateVoteLabels(by: 2, forNote: note)
                }
                else {
                    
                    self.updateVoteLabels(by: 1, forNote: note)
                }
                
                thisUser.updateNote(uuid: note.uuid, canUpvote: false, canDownvote: true)
                
                self.saveNotes()
                
                let noteUpdates = [ "/base/notes/\(note.uuid)" : note.toAny() ]
                let userUpdates = [ "\(userPath)/votes/\(note.uuid)" : note.toAny()]
                
                firebaseReference.updateChildValues(noteUpdates)
                firebaseReference.updateChildValues(userUpdates)
            }
        }
    }
    
    open func downvoteTapGesture() {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.downvoteButton?.transform = CGAffineTransform(scaleX: 2, y: 2)
            
            
        }, completion: { finished in
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.downvoteButton?.transform = CGAffineTransform.identity
                
            }, completion: nil)
        })
        
        if let annotation = self.annotation {
            
            let note = Note(uuid: annotation.uuid, time: annotation.time, lat: annotation.lat, long: annotation.lon, text: annotation.title!, upvotes: annotation.upvotes, downvotes: annotation.downvotes, reports: annotation.reports, user: annotation.user, comments: annotation.comments)!
            
            if thisUser.canDownvote(uuid: note.uuid) {
                
                if thisUser.hasInteracted(with: note.uuid) {
                    
                    self.updateVoteLabels(by: -2, forNote: note)
                }
                else {
                    
                    self.updateVoteLabels(by: -1, forNote: note)
                }
                
                thisUser.updateNote(uuid: note.uuid, canUpvote: true, canDownvote: false)
                
                self.saveNotes()
            }
        }
    }
    
    open func tapGesture()
    {
        if let annotation = self.annotation
        {
            
            if let note = Note(uuid: annotation.uuid, time: annotation.time, lat: annotation.lat, long: annotation.lon, text: annotation.title!, upvotes: annotation.upvotes, downvotes: annotation.downvotes, reports: annotation.reports, user: annotation.user, comments: annotation.comments) {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let commentsTableViewController = storyboard.instantiateViewController(withIdentifier: "FNCommentsTableViewController") as! FNCommentsTableViewController
                
                commentsTableViewController.pathToFollow = note.uuid
                commentsTableViewController.projectText = note.text
                commentsTableViewController.votesNumber = String(Int(note.upvotes)! - Int(note.downvotes)!)
                commentsTableViewController.timeText = note.time
                
                self.parentViewController?.navigationController?.pushViewController(commentsTableViewController, animated: true)
            }
        }
    }

    
    func updateVoteLabels(by value: Int, forNote: Note) {
        
        self.numberOfVotes! += value
        
        if value > 0 {
            
            self.votesLabel!.text = "\(self.numberOfVotes!)"
            forNote.upvotes = String(Int(forNote.upvotes)! + 1)
            
            thisUser.updateNote(uuid: uuid, canUpvote: false, canDownvote: true)
            
            upvoteButton?.setImage(UIImage(named:"up-arrow")?.imageWithColor(color1: UIColor.init(red: 137/255.0, green: 42/255.0, blue: 214/255.0, alpha: 1)), for: .normal)
            downvoteButton?.setImage(UIImage(named:"down-arrow")?.imageWithColor(color1: UIColor.white), for: .normal)
        }
        else {
            self.votesLabel!.text = "\(self.numberOfVotes!)"
            forNote.downvotes = String(Int(forNote.downvotes)! + 1 )
            
            thisUser.updateNote(uuid: uuid, canUpvote: true, canDownvote: false)
            
            upvoteButton?.setImage(UIImage(named:"up-arrow")?.imageWithColor(color1: UIColor.white), for: .normal)
            downvoteButton?.setImage(UIImage(named:"down-arrow")?.imageWithColor(color1: UIColor.init(red: 137/255.0, green: 42/255.0, blue: 214/255.0, alpha: 1)), for: .normal)
        }
        
        let noteUpdates = [ "/base/notes/\(forNote.uuid)" : forNote.toAny() ]
        let userUpdates = [ "\(userPath)/votes/\(forNote.uuid)" : forNote.toAny()]
        
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
