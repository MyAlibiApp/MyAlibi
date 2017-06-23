//
//  FNHomeTableViewCell.swift
//  FloatNote
//
//  Created by Jared Downing on 10/14/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import UIKit

class FNHomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rowLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setUpConfig()
        
    }
    
    func setUpConfig() {
        
        let clearView = UIView()
        clearView.backgroundColor = UIColor.clear 
        UITableViewCell.appearance().selectedBackgroundView = clearView
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
}
