//
//  Constants.swift
//  FloatNote
//
//  Created by Jared Downing on 10/13/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseInstanceID
import MapKit
import HDAugmentedReality

var firebaseReference = FIRDatabase.database().reference()

//This
var thisUser = User(uuid: "Setup", karma: "Setup", reports: "Setup", viewedNotes: nil)
var thisNote = Note(uuid: "Setup", time: "Setup", lat: "Setup", long: "Setup", text: "Setup", upvotes: "Setup", downvotes: "Setup", reports: "Setup", user: "Setup", comments: "Setup")
var thisComment = Comment(uuid: "Setup", user: "Setup", time: "Setup", reports: "Setup", text: "Setup")

//Paths
var userPath = "Setup"

//Notes
var notes = [Note]()
var noteARAnnotations = [ARAnnotation]()
var noteMapAnnotations = [NoteAnnotation]()

//Bools
var fromNewNote: Bool = false
var pulledRefresh: Bool = false
var hasMovedPages: Bool = false
var hasLoadedAllNotes: Bool = false
var MapAnnotationOpen = false
var AllowSelectionChanges: Bool = true
var refreshing: Bool = false
var notesAddedToExplore: Bool = false

//Location
var currLocation = CLLocationCoordinate2D()
var MapLocationTouched: CGPoint = CGPoint(x: 0, y: 0)

// Debug
var DEBUG = false
