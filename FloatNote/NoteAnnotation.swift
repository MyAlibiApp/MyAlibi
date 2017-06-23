//
//  NoteAnnotation.swift
//  FloatNote
//
//  Created by Jared Downing on 10/12/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import MapKit

class NoteAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    //Note
    var uuid: String!
    var time: String!
    var text: String!
    var upvotes: String!
    var downvotes: String!
    var reports: String!
    var user: String!
    var comments: String!
    var lat: String!
    var lon: String!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}
