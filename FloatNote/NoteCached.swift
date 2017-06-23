//
//  NoteCached.swift
//  FloatNote
//
//  Created by Jared Downing on 11/4/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation

class NoteCached: NSObject, NSCoding {
    
    var uuid: String
    var canUpvote: Bool
    var canDownvote: Bool
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("note_cache")
    
    struct PropertyKey {
        
        static let uuidKey = "uuid"
        static let canUpvoteKey = "canUpvote"
        static let canDownvoteKey = "canDownVote"
        
    }
    
    init?(uuid: String, canUpvote: Bool, canDownvote: Bool) {
        
        self.uuid = uuid
        self.canUpvote = canUpvote
        self.canDownvote = canDownvote
        super.init()
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(uuid, forKey: PropertyKey.uuidKey)
        aCoder.encode(canUpvote, forKey: PropertyKey.canUpvoteKey)
        aCoder.encode(canDownvote, forKey: PropertyKey.canDownvoteKey)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let uuid = aDecoder.decodeObject(forKey: PropertyKey.uuidKey) as! String
        let canUpvote = aDecoder.decodeBool(forKey: PropertyKey.canUpvoteKey)
        let canDownvote = aDecoder.decodeBool(forKey: PropertyKey.canDownvoteKey)
        
        self.init(uuid: uuid, canUpvote: canUpvote, canDownvote: canDownvote)
        
    }
    
    func toAny() -> Any {
        
        return [
            
            "uuid": uuid,
            "canUpvote" : canUpvote,
            "canDownvote" : canDownvote
            
        ]
        
    }
    
    
}


