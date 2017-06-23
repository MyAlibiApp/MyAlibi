//
//  Comments.swift
//  FloatNote
//
//  Created by Jared Downing on 10/13/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation
import UIKit

class Comment: NSObject {
    
    var uuid: String
    var user: String
    var time: String
    var reports: String
    var text: String
    
    init?(uuid: String, user: String, time: String, reports: String, text: String) {
        
        self.uuid = uuid
        self.user = user
        self.time = time
        self.reports = reports
        self.text = text
        
    }
    
    func toAny() -> Any {
        
        return [
            
            "uuid": uuid,
            "user": user,
            "time": time,
            "reports": reports,
            "text": text
            
        ]
        
    }
    
}


