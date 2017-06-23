//
//  FNExploreViewController.swift
//
//  Created by Jared Downing on 11/18/2016
//  Copyright (c) 2016 Float Note, Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import HDAugmentedReality

class FNExploreViewController: FNLocationBaseViewController, ARDataSource
{
    
    @IBOutlet weak var searchImage: UIImageView!
    
    @IBOutlet weak var tapLabel: UIButton!
    
    
    
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
    let locationManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 1000
    
    var annotationText = [String]()
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setUpConfig()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if defaults.integer(forKey: "HasSeenExplore")  == 0 {
            defaults.set(1, forKey: "HasSeenExplore")
            //showTutorial()
        }
        
    }
    
    func setUpConfig() {
        
        hasMovedPages = true
        
        locationManager.desiredAccuracy = 1000
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
//        searchImage.image = searchImage.image?.imageWithColor(color1: UIColor(red: 137.0/255, green: 42.0/255, blue: 214.0/255, alpha: 1))
//        
//        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewPressed))
//        
//        self.view.addGestureRecognizer(viewTapGesture)
//        self.view.isUserInteractionEnabled = true
        
    }
    
    func showTutorial() {
    
            let alert = UIAlertController(title: "Explore", message: "Here you can view the Float Notes within 300 meters of your location", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
    }
    
    func viewPressed() {
        
        showARViewController()
        
    }
    
    func showARViewController()
    {
        
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            alert("Capture Error")
            return
        }
        
        let arViewController = ARViewController()
        arViewController.debugEnabled = false
        arViewController.dataSource = self
        arViewController.maxDistance = 300
        arViewController.maxVisibleAnnotations = 20
        arViewController.maxVerticalLevel = 3
        arViewController.headingSmoothingFactor = 0.05
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.hidesBottomBarWhenPushed = false
        arViewController.setAnnotations(noteARAnnotations)
        
        var canSeeAnnotations: Bool = false
        
        for an in noteARAnnotations {
            
            let currLoc = CLLocation(latitude: currLocation.latitude, longitude: currLocation.longitude)
            let anLocation = CLLocation(latitude: Double(an.lat)!, longitude: Double(an.lon)!)
            let dist = currLoc.distance(from: anLocation)
            
            if dist < 300 {
                
                let newNote = NoteCached(uuid: an.uuid, canUpvote: true, canDownvote: true)
                
                canSeeAnnotations = true
                
                if !thisUser.has(seen: an.uuid) {
                    thisUser.viewedNotes.append(newNote!)
                    saveNotes()
                }
            }
        }
       
        arViewController.onDidFailToFindLocation = {
            
            [weak self, weak arViewController] elapsedSeconds, acquiredLocationBefore in
                
            self?.handleLocationFailure(elapsedSeconds: elapsedSeconds, acquiredLocationBefore: acquiredLocationBefore, arViewController: arViewController)
        }
        
        self.navigationController?.hidesBottomBarWhenPushed = false
        
        self.navigationController?.pushViewController(arViewController, animated: true)
        
        
    }
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        let annotationView = FNAnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 350,height: 200)
        return annotationView;
    }
    
    fileprivate func getDummyAnnotations(centerLatitude: Double, centerLongitude: Double, delta: Double, count: Int) -> Array<ARAnnotation>
    {
        var annotations: [ARAnnotation] = []
        
        srand48(3)
        for i in stride(from: 0, to: count, by: 1)
        {
            let annotation = ARAnnotation()
            annotation.location = self.getRandomLocation(centerLatitude: centerLatitude, centerLongitude: centerLongitude, delta: delta)
            annotation.title = annotationText[i]
            annotations.append(annotation)
        }
        return annotations
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        
    }
    
    fileprivate func getRandomLocation(centerLatitude: Double, centerLongitude: Double, delta: Double) -> CLLocation
    {
        var lat = centerLatitude
        var lon = centerLongitude
        
        let latDelta = -(delta / 2) + drand48() * delta
        let lonDelta = -(delta / 2) + drand48() * delta
        lat = lat + latDelta
        lon = lon + lonDelta
        return CLLocation(latitude: lat, longitude: lon)
    }
    
    @IBAction func buttonTap(_ sender: AnyObject)
    {
        //showARViewController()
    }
    
    
    
    func handleLocationFailure(elapsedSeconds: TimeInterval, acquiredLocationBefore: Bool, arViewController: ARViewController?)
    {
        guard arViewController != nil else { return }
        
        NSLog("Failed to find location after: \(elapsedSeconds) seconds, acquiredLocationBefore: \(acquiredLocationBefore)")
        
        // Example of handling location failure
        if elapsedSeconds >= 20 && !acquiredLocationBefore
        {
            // Stopped bcs we don't want multiple alerts
           // arViewController.trackingManager.stopTracking()
            
            let alert = UIAlertController(title: "Problems", message: "Cannot find location, use Wi-Fi if possible!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Close", style: .cancel)
            {
                (action) in
                
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            
            self.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK : Notes
extension FNExploreViewController {
    // TODO: Load Notes when updated
}

//MARK: Note Cache 
extension FNExploreViewController {
    
    func saveNotes() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(thisUser.viewedNotes, toFile: NoteCached.ArchiveURL.path)
        
        if !isSuccessfulSave {
            
            print("Failed to save notes...")
            
        }
        
    }
    
}

extension FNExploreViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(locations.count == 0){
            alert("Cannot fetch your location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alert("Cannot fetch your location")
    }
    
    fileprivate func alert(_ message : String) {
//        let alert = UIAlertController(title: "Oops something went wrong.", message: message, preferredStyle: UIAlertControllerStyle.alert)
//        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
//        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) { (action) -> Void in
//            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
//            return
//        }
//        alert.addAction(settings)
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
    }
    
}
