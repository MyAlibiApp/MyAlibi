//
//  User.swift
//  FloatNote
//
//  Created by Jared Downing on 10/13/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//


import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class User: NSObject {
    
    var uuid: String
    var karma: String
    var reports: String
    var viewedNotes = [NoteCached]()
    
    init(uuid: String, karma: String,  reports: String, viewedNotes: [NoteCached]?) {
        
        self.uuid = uuid
        self.karma = karma
        self.reports = reports
        
    }
    
    func toAny() -> Any {
        
        return [
            
            "uuid": uuid,
            "karma": karma,
            "reports": reports
        ]
        
    }
    
    func has(seen uuid: String) -> Bool {
        
        if note(with: uuid) != nil {
            return true
        }
        
        return false
    }
    
    func hasInteracted(with uuid: String) -> Bool{
        
        if let note = note(with: uuid) {
            
            if (!note.canUpvote && note.canDownvote) || (!note.canDownvote && note.canUpvote){
                
                return true
            }
        }
        
        return false
    }
    
    func canUpvote(uuid: String) -> Bool {
        
        if let note = note(with: uuid) {
            if note.canUpvote {
                return true
            }
        }
        
        return false
    }
    
    func canDownvote(uuid: String) -> Bool {
        
        if let note = note(with: uuid) {
            if note.canDownvote {
                return true
            }
        }
        
        return false
    }
    
    func updateNote(uuid: String, canUpvote: Bool, canDownvote: Bool) {
        
        for note in viewedNotes {
            
            if note.uuid == uuid {
                
                note.canUpvote = canUpvote
                note.canDownvote = canDownvote
            }
        }
    }
    
    func note(with uuid: String) -> NoteCached? {
        
        for note in viewedNotes {
            
            if note.uuid == uuid {
                
                return note
            }
        }
        
        return nil
    }
    
    
    func saveNoteCache() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(viewedNotes, toFile: NoteCached.ArchiveURL.path)
        
        if !isSuccessfulSave {
            
            print("Failed to save notes...")
            
        }
        
    }
    
}

