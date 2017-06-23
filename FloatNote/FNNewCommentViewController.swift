//
//  FNNewCommentViewController.swift
//  FloatNote
//
//  Created by Jared Downing on 11/4/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation
import UIKit

class FNNewCommentViewController: UIViewController {
    
    @IBOutlet weak var postTextField: UITextField!
    
    @IBOutlet weak var keyboardToolBar: UIToolbar!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    
    var comment: Comment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupConfig()
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
        
        navigationController?.performSegue(withIdentifier: "unwindCommentsSegue", sender: self)
        
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
            let text = postTextField.text ?? ""
            
            comment = Comment(uuid: "", user: thisUser.uuid, time: time, reports: "0", text: text)
            
        }
        else {
            
            // Cancel pressed
            
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

