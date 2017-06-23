//
//  SecondViewController.swift
//  FloatNote
//
//  Created by Jared Downing on 10/11/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import UIKit
import MapKit
import HDAugmentedReality
import Firebase
import FirebaseDatabase
import HDAugmentedReality


class FNMapViewController: FNLocationBaseViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var loadingBackgroundImageView: UIImageView!
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    //Map
    let locationManager = CLLocationManager()
    var hasCentered: Bool = false
    var calloutView: CustomCalloutView!
    var calloutBackground: UIImageView!
    var calloutIsOpen: Bool = false
    
    //Data
    var notesLoaded: Bool = false
    var defaults = UserDefaults.standard
    
    //Notes
    var newNoteRefHandle: FIRDatabaseHandle?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupConfig()
        
    }
    
    func setupConfig() {
        
        setupLocation()
        setupLoading()
        showTermsOfService()
        loadUser()
        setupRefesh()
      
    }
    
    func setupRefesh() {
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(refreshPage))
        refreshButton.tintColor = UIColor.clear
        
        
        self.tabBarController?.navigationItem.leftBarButtonItem = refreshButton
        
    }
    
    func showTutorial() {
        
        if defaults.integer(forKey: "HasSeenMap") == 0 {
            
            defaults.set(1, forKey: "HasSeenMap")
            
            let alert = UIAlertController(title: "Welcome", message: "This is the map page. You can view the location of notes around you here.", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showTermsOfService() {
        
        if defaults.integer(forKey: "HasAcceptedTerms") == 0 {
            
            let alert = UIAlertController(title: "Terms of Service.", message: TermsOfService, preferredStyle: UIAlertControllerStyle.alert)
            let accept = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { _ in
                
                self.defaults.set(1, forKey: "HasAcceptedTerms")
                self.setupLocation()
            }
            
            let no = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
                _ in
                self.showMustAccept()
            }
            
            let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.40)
            
            alert.view.addConstraint(height);
            alert.addAction(accept)
            alert.addAction(no)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func showMustAccept() {
        
        let alert = UIAlertController(title: "Warning", message: "You must accept the Terms of Service to use Float Note.", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
            _ in
            
                self.showTermsOfService()
            
        }
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func refreshPage() {
        
        if !refreshing {
            
            refreshing = true
            
            self.loadingBackgroundImageView.isHidden = false
            self.loadingBackgroundImageView.alpha = 1
            self.loadingLabel.isHidden = false
            self.loadingLabel.alpha = 1
            animateLoading(on: true)
            
            resetNotes()
            observeNotes()
        }
        
    }
    
    func resetNotes() {
        
        notesLoaded = false
        notesAddedToExplore = false
        
        mapView.removeAnnotations(mapView.annotations)
        notes = []
        noteARAnnotations = []
        noteMapAnnotations = []
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        
        if hasMovedPages {
            
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                alert("Cannot fetch your location")
                return
            case .authorizedAlways, .authorizedWhenInUse:
                refreshPage()
                
            }
            
        }
        
        if fromNewNote {
            showNewNote()
        }
    }
    
    func showNewNote() {
        
        fromNewNote = false
        
        let alert = UIAlertController(title: "Success!", message: "A new note was posted at your location", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func setupLoading() {
        
        loadingBackgroundImageView.image = UIImage(color: UIColor.gray.withAlphaComponent(0.7))
        animateLoading(on: true)
        
    }
    
    func animateLoading(on: Bool) {
        
        if !notesLoaded {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                
                self.loadingBackgroundImageView.alpha = 0.8
                
                }, completion: { finished in
                    
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                        
                        self.loadingBackgroundImageView.alpha = 0.5
                        
                        }, completion: { finished in
                            
                            self.animateLoading(on: true)
                            
                    })
            })
        }
        else {
            
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
                
                self.loadingBackgroundImageView.alpha = 0
                
            }, completion: nil)
        }
        
    }
    
    func setupLocation() {
        
        mapView.delegate = self
        
        locationManager.desiredAccuracy = 1000
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func unwindToProjectList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? FNPostViewController {
            
            if let note = sourceViewController.note {
                
                thisNote = note
                
                if note.text != "" {
                    
                    create(note: note)
                    
                }
            }
        }
    }
    
    func create(note: Note) {
        
        notes.append(note)
        
        let noteKey = firebaseReference.child("notes").childByAutoId().key
        let commentsKey = firebaseReference.child("comments").childByAutoId().key
        
        if let karma = Int(thisUser.karma) {
            thisUser.karma = String(karma + 10)
        }
        
        note.uuid = noteKey
        note.lat = currLocation.latitude.description
        
        let randomLon: Double = Double("0.0000" + String(Int(arc4random_uniform(4))) + "0")!
            
        note.long = String(currLocation.longitude + randomLon)
        
        let blankText = "init"
        let blankComment = Comment(uuid: commentsKey, user: blankText, time: blankText, reports: blankText, text: blankText)
        
        let noteUpdates = [ "/base/notes/\(noteKey)" : note.toAny(), "/base/comments/\(noteKey)/\(commentsKey)": blankComment!.toAny() ]
        let userUpdates = [ "\(userPath)/notes/\(noteKey)" : note.toAny()]
        
        firebaseReference.updateChildValues(noteUpdates)
        firebaseReference.updateChildValues(userUpdates)
        
        refreshPage()
        
        if let newNote = NoteCached(uuid: noteKey, canUpvote: true, canDownvote: true) {
            create(cache: newNote)
        }
    }
    
    func addFakeNote(time: String, lat: String, lon: String, text: String, upvotes: String, downvotes: String) {
       
        
        let user = thisUser.uuid
        let noteKey = firebaseReference.child("notes").childByAutoId().key
        let commentsKey = firebaseReference.child("comments").childByAutoId().key
        
        let note = Note(uuid: noteKey, time: time, lat: lat,  long: lon, text: text, upvotes: upvotes, downvotes: downvotes,  reports: "0", user: user, comments: "0")
        
        let blankText = "init"
        let blankComment = Comment(uuid: commentsKey, user: blankText, time: blankText, reports: blankText, text: blankText)
        
        let noteUpdates = [ "/base/notes/\(noteKey)" : note!.toAny(), "/base/comments/\(noteKey)/\(commentsKey)": blankComment!.toAny() ]
        let userUpdates = [ "\(userPath)/notes/\(noteKey)" : note!.toAny()]
        
        firebaseReference.updateChildValues(noteUpdates)
        firebaseReference.updateChildValues(userUpdates)
      
    }
    
    func create(cache: NoteCached) {
        
        thisUser.viewedNotes.append(cache)
        saveNotes()
        
    }
    
    func addFakeNotes() {}
    
}

// MARK: NoteCache
extension FNMapViewController {
    
    func loadedNoteCache() -> [NoteCached]? {
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: NoteCached.ArchiveURL.path) as? [NoteCached]
        
    }
    
    func saveNotes() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(thisUser.viewedNotes, toFile: NoteCached.ArchiveURL.path)
        
        if !isSuccessfulSave {
            
            print("Failed to save notes...")
            
        }
        
    }
    
    
}

func loadNew(new user: User) {
    
}

//MARK: Data Construction
extension FNMapViewController {
    
    func loadUser() {
        
        if defaults.integer(forKey: "HasCreatedNewUser") == 0 {
            let user =  User(uuid: "", karma: "0", reports: "0", viewedNotes: nil)
            create(user:user)
        }
        else {
            
            thisUser.uuid = defaults.value(forKey: "UserUUID") as! String
            thisUser.karma = defaults.value(forKey: "UserKarma") as! String
            thisUser.reports = defaults.value(forKey: "UserReports") as! String
            
            if let loadedNoteCache = loadedNoteCache() {
                thisUser.viewedNotes = loadedNoteCache
            }
            else {
                
                let noteCache = [NoteCached]()
                thisUser.viewedNotes = noteCache
                saveNotes()
                
            }
            
            userPath = "/base/users/\(thisUser.uuid)"
            
        }
        
    }
    
    func create(user: User) {
        
        let userKey = firebaseReference.child("users").childByAutoId().key
        let notesCached = [NoteCached]()
        
        thisUser = User(uuid: userKey, karma: "0", reports: "0", viewedNotes: notesCached)
        
        defaults.set(userKey, forKey: "UserUUID")
        defaults.set("0", forKey: "UserKarma")
        defaults.set("0", forKey: "UserReports")
        
        userPath = "/base/users/\(userKey)"
        
        let blankText = "init"
        if let blankInitialNote = Note(uuid: blankText, time: blankText, lat: blankText, long: blankText, text: blankText, upvotes: blankText, downvotes: blankText, reports: blankText, user: blankText, comments: blankText) {
            
            let thisUserVotesUpdates = ["\(userPath)/votes/\(blankInitialNote.uuid)/" : blankInitialNote.toAny()]
            let thisUserNotesUpdates = ["\(userPath)/notes/\(blankInitialNote.uuid)/" : blankInitialNote.toAny()]
            let thisUserCommentsUpdates = ["\(userPath)/comments/\(blankInitialNote.uuid)/" : blankInitialNote.toAny()]
            let thisUserStatsUpdates = ["\(userPath)/stats/" : thisUser.toAny()]
            
            firebaseReference.updateChildValues(thisUserVotesUpdates)
            firebaseReference.updateChildValues(thisUserNotesUpdates)
            firebaseReference.updateChildValues(thisUserCommentsUpdates)
            firebaseReference.updateChildValues(thisUserStatsUpdates)
            
            defaults.set(1, forKey: "HasCreatedNewUser")
        }
        
    }
    
    func observeNotes() {
        
        let noteQuery = firebaseReference.child("base").child("notes")
        
        newNoteRefHandle = noteQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            if let noteValues = snapshot.value as? Dictionary<String, String> {
                
                if let time = noteValues["time"] as String!,
                    let lat = noteValues["lat"] as String!,
                    let long = noteValues["long"] as String!,
                    let text = noteValues["text"] as String!,
                    let upvotes = noteValues["upvotes"] as String!,
                    let downvotes = noteValues["downvotes"] as String!,
                    let reports = noteValues["reports"] as String!,
                    let user = noteValues["user"] as String!,
                    let comments = noteValues["comments"] as String!,
                    let uuid = noteValues["uuid"] as String!{
                    
                    if let noteToAdd = Note(uuid: uuid, time: time, lat: lat,  long: long, text: text, upvotes: upvotes, downvotes: downvotes,  reports: reports, user: user, comments: comments) {
                        
                        self.addNew(note: noteToAdd)
                    }
                }
            }
        })
        
        self.finishLoadingNotes()
    }
    
    func addNew(note: Note) {
        
        notes.append(note)
        
        addARAnnotation(for: note)
        addMapAnnotation(for: note)
    }
    
    func loadNotes() {
        
        firebaseReference.child("base").child("notes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.value == nil) || ((snapshot.value as? NSNull?) == nil) {
                
                self.alert("Could not load notes. Try refreshing.")
                
                return
            
            }
                    
            if let noteJSONValues = snapshot.value as! [String: NSDictionary]? {
                
                for note in noteJSONValues {
                    
                    let noteValues = note.1
                    
                    if let time = noteValues["time"] as? String,
                    let lat = noteValues["lat"] as? String,
                    let long = noteValues["long"] as? String,
                    let text = noteValues["text"] as? String,
                    let upvotes = noteValues["upvotes"] as? String,
                    let downvotes = noteValues["downvotes"] as? String,
                    let reports = noteValues["reports"] as? String,
                    let user = noteValues["user"] as? String,
                    let comments = noteValues["comments"] as? String {
                        
                    if let noteToAdd = Note(uuid: note.0, time: time, lat: lat,  long: long, text: text, upvotes: upvotes, downvotes: downvotes,  reports: reports, user: user, comments: comments) {
                        
                        notes.append(noteToAdd)
                        
                    }
                        
                }
                    
            }
                
            DispatchQueue.main.async { () -> Void in
                self.finishLoadingNotes()
            }
                
            }
            
        }) { (error) in
            
            self.alert("Could not load notes. Try refreshing.")
            print(error)
        }
        
    }
    
    func finishLoadingNotes() {
    
        refreshing = false
        notesLoaded = true
        
        if notes.count > 0 {
            
            loadingBackgroundImageView.alpha = 0
            loadingBackgroundImageView.isHidden = true
            
            loadingLabel.isHidden = true
            loadingLabel.alpha = 0
        }
    }
    
//    func addAnnotations() {
//        
//        addMapAnnotations()
//        addARAnnotations()
//    }
    
}

//MARK: Map Alterations
extension UIView {
    
    func overlapHitTest(_ point: CGPoint, with event: UIEvent?, invisibleOn: Bool = false) -> UIView?  {
        
        let invisible = (isHidden || alpha == 0) && invisibleOn
        
        if !isUserInteractionEnabled || invisible {
            return nil
        }
        
        var hitView: UIView? = self
        if !self.point(inside: point, with: event) {
            if clipsToBounds {
                return nil
            } else {
                hitView = nil
            }
        }
        
        for subview in subviews.reversed() {
            let insideSubview = convert(point, to: subview)
            if let sview = subview.overlapHitTest(insideSubview, with: event) {
                return sview
            }
        }
        return hitView

    }
    
}

extension MKAnnotationView {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let rect: CGRect = self.bounds
        var isInside: Bool = rect.contains(point)
        
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point)
                if (isInside) {
                    AllowSelectionChanges = false
                    return isInside
                }
                
            }
            AllowSelectionChanges = true
        }
        
        return isInside
    }
    
    
}

extension AnnotationView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        _ = super.hitTest(point, with: event)
        
        return overlapHitTest(point, with: event)
    }
    
}

extension MKMapView {

    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return AllowSelectionChanges
        
    }
}

//MARK: Map View
extension FNMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        
        if annotationView == nil {
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }
        else {
            annotationView?.annotation = annotation
        }
        
        if let noteAnnotation = annotation as? NoteAnnotation {
            
            let noteLocation =  CLLocation(latitude: Double(noteAnnotation.lat)!, longitude: Double(noteAnnotation.lon)!)
            let currLoc = CLLocation(latitude: currLocation.latitude, longitude: currLocation.longitude)
            
            if noteLocation.distance(from: currLoc) < 300 {
                
                annotationView?.image = UIImage(named: "BlackPin")
                noteAnnotation.text = "This note is within 300 meters of you! Go to the 'Explore' tab to view it."
                
                
                return annotationView
            }
            else {
                
                annotationView?.alpha = 0
                annotationView?.image = UIImage(named: "GreenPin")
                return annotationView
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView){
        
        if view.annotation is MKUserLocation {return}
        
        if let noteAnnotation = view.annotation as? NoteAnnotation {
            
            showCallout(from: noteAnnotation)
            view.addSubview(calloutBackground)
            view.addSubview(calloutView)
        }
        
        if let coordinateSet = view.annotation?.coordinate {
            mapView.setCenter(coordinateSet, animated: true)
        }
    }
    
    func showCallout(from note: NoteAnnotation) {
        
        calloutIsOpen = true
        MapAnnotationOpen = true
        
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        calloutView = views?[0] as! CustomCalloutView
        calloutBackground = UIImageView(image: UIImage(named: "ImageBack"))
        
        thisNote = Note(uuid: note.uuid, time: note.time, lat: note.coordinate.latitude.description, long: note.coordinate.longitude.description, text: note.text, upvotes: note.upvotes, downvotes: note.downvotes, reports: note.reports, user: note.user, comments: note.comments)
        
        
        calloutView.layer.cornerRadius = 40
        calloutView.layer.masksToBounds = true
        
        
        let currentDate = Date()
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let convertedNoteDate = formatter.date(from: note.time) {
            let diff = currentDate.offset(from: convertedNoteDate)
            calloutView.noteTime.text = "\(String(describing: diff))"
        }
        else {
            calloutView.noteTime.text = "\(String(describing: currentDate))"
        }
        
        let upvoteTapGesture = UITapGestureRecognizer(target: self, action: #selector(upvotePressed))
        let downvoteTapGesture = UITapGestureRecognizer(target: self, action: #selector(downvotePressed))
        let commentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(commentsPressed))
        
        calloutView.upvoteButton.addGestureRecognizer(upvoteTapGesture)
        calloutView.downvoteButton.addGestureRecognizer(downvoteTapGesture)
        calloutView.commentsButton.addGestureRecognizer(commentsTapGesture)
        
        calloutView.upvoteButton.isUserInteractionEnabled = true
        calloutView.downvoteButton.isUserInteractionEnabled = true
        calloutView.commentsButton.isUserInteractionEnabled = true
        
        calloutView.noteComments.alpha = 0
        
        calloutView.upvoteButton.image = calloutView.upvoteButton.image?.imageWithColor(color1: UIColor.lightGray)
        calloutView.downvoteButton.image = calloutView.downvoteButton.image?.imageWithColor(color1: UIColor.lightGray)
        calloutView.commentsButton.image = calloutView.commentsButton.image?.imageWithColor(color1: UIColor.lightGray)
        calloutView.commentsButton.alpha = 0
        calloutView.shareButton.image = calloutView.shareButton.image?.imageWithColor(color1: UIColor.clear)
        
        calloutView.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        
        calloutBackground.frame = CGRect(x: 0, y: 0, width: calloutView.frame.width + 20, height: calloutView.frame.height + 15)
        calloutBackground.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        calloutBackground.center = CGPoint(x: view.bounds.size.width / 2 + 5, y: -calloutView.bounds.size.height*0.52 + 5)
    }
    
    func commentsPressed() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentsTableViewController = storyboard.instantiateViewController(withIdentifier: "FNCommentsTableViewController") as! FNCommentsTableViewController
   
        if let uuid = thisNote?.uuid, let text = thisNote?.text, let upvotes = thisNote?.upvotes, let downvotes = thisNote?.downvotes, let time = thisNote?.time {
            
            commentsTableViewController.pathToFollow = uuid
            commentsTableViewController.projectText = text
            commentsTableViewController.timeText = time
            
            if let upvotesInt = Int(upvotes), let downvotesInt = Int(downvotes) {
                let votesNumber = String(upvotesInt - downvotesInt)
                commentsTableViewController.votesNumber = votesNumber
            }
            
            self.navigationController?.pushViewController(commentsTableViewController, animated: true)
            
        }
        else {
            alert("Unable to load comments.")
        }
        
    }
    
    func upvotePressed() {
        
        UIView.animate(withDuration: 0.1, animations: {
        
            self.calloutView.upvoteButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        
        
        }, completion: { finished in
        
            UIView.animate(withDuration: 0.1, animations: {
                
                self.calloutView.upvoteButton.transform = CGAffineTransform.identity
                
                }, completion: nil)
        })
        
        if let uuid = thisNote?.uuid {
            
            if !thisUser.has(seen: uuid) {
                
                let newNote = NoteCached(uuid: uuid, canUpvote: true, canDownvote: true)
                thisUser.viewedNotes.append(newNote!)
                saveNotes()
            }
            
            if thisUser.canUpvote(uuid: uuid) {
                
                if self.calloutView.noteText.text != "This note is within 300 meters of you! Go to the 'Explore' tab to view it."  {
                    
                    if thisUser.hasInteracted(with: uuid) {
                        updateVoteLabels(by: 2)
                    }
                    else {
                        updateVoteLabels(by: 1)
                    }
                    
                    thisUser.updateNote(uuid: uuid, canUpvote: false, canDownvote: true)
                }
            }
        }
        
        saveNotes()
    }
    
    func downvotePressed() {
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.calloutView.downvoteButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            
            
            }, completion: { finished in
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    self.calloutView.downvoteButton.transform = CGAffineTransform.identity
                    
                    
                    }, completion: nil)
                
        })
        
        if let uuid = thisNote?.uuid {
            
            if !thisUser.has(seen: uuid) {
                
                let newNote = NoteCached(uuid: uuid, canUpvote: true, canDownvote: true)
                thisUser.viewedNotes.append(newNote!)
                saveNotes()
            }
            
            if thisUser.canDownvote(uuid: uuid) {
                
                if self.calloutView.noteText.text != "This note is within 300 meters of you! Go to the 'Explore' tab to view it." {
                    
                    if thisUser.hasInteracted(with: uuid) {
                        updateVoteLabels(by: -2)
                    }
                    else {
                        updateVoteLabels(by: -1)
                    }
                    
                    thisUser.updateNote(uuid: uuid, canUpvote: true, canDownvote: false)
                }
            }
        }
        
        saveNotes()
        
    }
    
    func updateNoteAnnotation() {
        
        for i in mapView.annotations {
            
            if !(i is MKUserLocation) {
                
                let na = i as! NoteAnnotation
                
                if na.uuid == thisNote!.uuid {
                    
                    na.upvotes = thisNote!.upvotes
                    na.downvotes = thisNote!.downvotes
                    
                }
            }
        }
        
    }
    
    func updateVoteLabels(by value: Int) {
        
        
        
        calloutView.noteVotes.text = String(Int(calloutView.noteVotes.text!)! + value)
        
        if value > 0 {
            
            calloutView.upvoteButton.image = calloutView.upvoteButton.image?.imageWithColor(color1: UIColor.purple)
            calloutView.downvoteButton.image = calloutView.downvoteButton.image?.imageWithColor(color1: UIColor.lightGray)
            
            thisNote!.upvotes = String(Int(thisNote!.upvotes)! + 1)
            
        }
        else {
            
            calloutView.upvoteButton.image = calloutView.upvoteButton.image?.imageWithColor(color1: UIColor.lightGray)
            calloutView.downvoteButton.image = calloutView.downvoteButton.image?.imageWithColor(color1: UIColor.purple)
            
            thisNote!.downvotes = String(Int(thisNote!.downvotes)! + 1)
            
        }
        
        updateNoteAnnotation()
        
        let noteUpdates = [ "/base/notes/\(thisNote!.uuid)" : thisNote!.toAny() ]
        let userUpdates = [ "\(userPath)/votes/\(thisNote!.uuid)" : thisNote!.toAny()]
        
        firebaseReference.updateChildValues(noteUpdates)
        firebaseReference.updateChildValues(userUpdates)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      
        if view.isKind(of: AnnotationView.self) {
            
            for subview in view.subviews {
                
                //Animate close
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    
                    subview.alpha = 0
                    subview.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    
                    }, completion: { finished in
                        
                        subview.removeFromSuperview()
                        
                })
                
            }
            
        }
    }
}

//MARK: Location Manager
extension FNMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(locations.count > 0){
            
            currLocation = locations[0].coordinate
            
            if !hasCentered {
                
                centerMap()
                
            }
            
        }
        else {
            
            alert("Cannot fetch your location")
            
        }
    }
    
    func centerMap() {
        
        if !refreshing {
            observeNotes()
        }
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currLocation.latitude, longitude: currLocation.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        self.mapView.showsUserLocation = true
        self.mapView.setRegion(region, animated: true)
        self.mapView.tintColor = UIColor(red: 137.0/255, green: 42.0/255, blue: 214.0/255, alpha: 1)
        
        
        let eyeCoordinate = CLLocationCoordinate2D(latitude: currLocation.latitude - 0.02, longitude: currLocation.longitude)
        let mapCamera = MKMapCamera(lookingAtCenter: currLocation, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 500.0)
        
        UIView.animate(withDuration: 2, delay: 2, options: .curveEaseIn, animations: {
            
            self.mapView.setCamera(mapCamera, animated: true)
            
        }, completion: nil)
        
        hasCentered = true
        
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alert("Cannot fetch your location")
    }
    
//    
//    func addARAnnotations() {
//        
//        noteARAnnotations = []
//        
//        for i in stride(from: 0, to: notes.count, by: 1) {
//            
//            let annotation = ARAnnotation()
//            annotation.location = CLLocation(latitude: Double(notes[i].lat)!, longitude: Double(notes[i].long)! )
//            annotation.title = notes[i].text
//            annotation.upvotes = notes[i].upvotes
//            annotation.downvotes = notes[i].downvotes
//            annotation.lon = notes[i].long
//            annotation.lat = notes[i].lat
//            annotation.comments = notes[i].comments
//            annotation.reports = notes[i].reports
//            annotation.user = notes[i].user
//            annotation.uuid = notes[i].uuid
//            annotation.time = notes[i].time
//            
//            noteARAnnotations.append(annotation)
//            
//        }
//        
//    }
//    
//    func addMapAnnotations() {
//        
//        noteMapAnnotations = []
//        
//        for i in stride(from: 0, to: notes.count, by: 1) {
//            
//            let annotation = NoteAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(notes[i].lat)!, longitude: Double(notes[i].long)! ))
//            
//            annotation.time = notes[i].time
//            annotation.text = notes[i].text
//            annotation.uuid = notes[i].uuid
//            annotation.user = notes[i].user
//            annotation.reports = notes[i].user
//            annotation.lat = notes[i].lat
//            annotation.lon = notes[i].long
//            annotation.upvotes =  notes[i].upvotes
//            annotation.downvotes = notes[i].downvotes
//            annotation.comments = notes[i].comments
//            noteMapAnnotations.append(annotation)
//            
//        }
//        
//        self.mapView.addAnnotations(noteMapAnnotations)
//        
//    }
//    
    func addMapAnnotation(for note: Note) {
        
        let annotation = NoteAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(note.lat)!, longitude: Double(note.long)! ))
        
        annotation.time = note.time
        annotation.text = note.text
        annotation.uuid = note.uuid
        annotation.user = note.user
        annotation.reports = note.reports
        annotation.lat = note.lat
        annotation.lon = note.long
        annotation.upvotes = note.upvotes
        annotation.downvotes = note.downvotes
        annotation.comments = note.comments
        
        noteMapAnnotations.append(annotation)
        
        mapView.addAnnotation(annotation)
    }
    
    func addARAnnotation(for note: Note) {
        
        let annotation = ARAnnotation()
        
        annotation.location = CLLocation(latitude: Double(note.lat)!, longitude: Double(note.long)!)
        annotation.title = note.text
        annotation.upvotes = note.upvotes
        annotation.downvotes = note.downvotes
        annotation.lon = note.long
        annotation.lat = note.lat
        annotation.comments = note.comments
        annotation.reports = note.reports
        annotation.user = note.user
        annotation.uuid = note.uuid
        annotation.time = note.time
        
        noteARAnnotations.append(annotation)
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch(CLLocationManager.authorizationStatus()) {
        case .notDetermined, .restricted, .denied:
            print("No access")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access")
            showTutorial()
        }
    }
    
    fileprivate func alert(_ message : String) {
        
//        let alert = UIAlertController(title: "Oops something went wrong.", message: message, preferredStyle: UIAlertControllerStyle.alert)
//        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
//        
//            _ in
//            
//            if !isInternetAvailable() {
//                
//                self.alert("Could not connect to network")
//                
//            }
//            
//        }
//        
//        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) { (action) -> Void in
//            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
//            return
//        }
//        alert.addAction(settings)
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
    }
}


