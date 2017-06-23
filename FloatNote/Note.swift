//
//  Note.swift
//  FloatNote
//
//  Created by Jared Downing on 10/12/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation
import UIKit

open class Note: NSObject {
    
    var uuid: String
    var time: String
    var lat: String
    var long: String
    var text: String
    var upvotes: String
    var downvotes: String
    var reports: String
    var user: String
    var comments: String
    
    init?(uuid: String, time: String, lat: String,  long: String, text: String, upvotes: String, downvotes: String,  reports: String, user: String, comments: String) {
        
        self.uuid = uuid
        self.time = time
        self.lat = lat
        self.long = long
        self.text = text
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.reports = reports
        self.user = user
        self.comments = comments
        
    }
    
    func toAny() -> Any {
        
        return [
            
            "uuid": uuid,
            "time": time,
            "lat": lat,
            "long" : long,
            "text": text,
            "upvotes": upvotes,
            "downvotes" : downvotes,
            "reports": reports,
            "user": user,
            "comments" : comments
            
        ]
        
    }
    
}

