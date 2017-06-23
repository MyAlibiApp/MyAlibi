//
//  AppDelegate.swift
//  FloatNote
//
//  Created by Jared Downing on 10/11/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        setup()
        
        return true
    }
    
    func setup() {
        
        setupAppearance()
        setupFlurry()
        setupFirebase()
    }
    
    func setupAppearance() {
        
        UITabBar.appearance().barTintColor = UIColor.myAlibiBlue()
        UITabBar.appearance().tintColor = UIColor.white
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white ], for: .selected)
        
        UINavigationBar.appearance().barTintColor = UIColor.myAlibiBlue()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    func setupFlurry() {
        
    }
    
    func setupFirebase() {
        
        //FIRApp.configure()
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

}

//MARK: Color Scheme
extension UIColor {
    
    static func myAlibiBlue() -> UIColor {
        
        return UIColor.init(red: 60.0/255.0, green: 75.0/255.0, blue: 82.0/255.0, alpha: 1.0)
    }
    
    static func myAlibiGold() -> UIColor {
        
        return UIColor.init(red: 255.0/255.0, green: 153.0/255.0, blue: 1.0/255.0, alpha: 1.0)
    }
    
    static func myAlibiRed() -> UIColor {
        
        return UIColor.init(red: 200.0/255.0, green: 38.0/255.0, blue: 5.0/255.0, alpha: 1.0)
    }
    
    static func myAlibiGray() -> UIColor {
        
        return UIColor.init(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    }
}
