//
//  FNPostViewController.swift
//  FloatNote
//
//  Created by Jared Downing on 10/12/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation
import UIKit

class FNPostViewController: UIViewController {
    
    @IBOutlet weak var postTextField: UITextField!
    
    @IBOutlet weak var keyboardToolBar: UIToolbar!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    
    var note: Note!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        
        postTextField.becomeFirstResponder()
        
    }
    
    func setupConfig() {
        
        keyboardToolBar.removeFromSuperview()
        keyboardToolBar.sizeToFit()
        
        postTextField.inputAccessoryView = keyboardToolBar
        
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(editTextField))
        
        self.view.addGestureRecognizer(viewTapGesture)
        self.view.isUserInteractionEnabled = true
        
    }
    
    func addTapped() {
        
        navigationController?.performSegue(withIdentifier: "unwindSegue", sender: self)
        
    }
    
    func cameraTapped() {
        
        print("CameraTapped")
        
    }
    
    func editTextField() {
        
        postTextField.becomeFirstResponder()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if sender as? UIBarButtonItem === postButton  {
            
            let currentDate = NSDate()
            
            let time = String(describing: currentDate)
            let lat = ""
            let long = ""
            let text = postTextField.text ?? ""
            let upvotes = "0"
            let downvotes = "0"
            let reports = "0"
            let user = thisUser.uuid
            let comments = "0"
            
            note = Note(uuid: "", time: time, lat: lat,  long: long, text: text, upvotes: upvotes, downvotes: downvotes,  reports: reports, user: user, comments: comments)
            
            if text != "" {
                fromNewNote = true
            }
            
        } else {
            
            // Cancel pressed
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
