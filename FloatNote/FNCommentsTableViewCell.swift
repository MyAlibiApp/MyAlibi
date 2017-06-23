//
//  FNCommentsTableViewCell.swift
//  FloatNote
//
//  Created by Jared Downing on 10/22/16.
//  Copyright © 2016 FloatNote. All rights reserved.
//

import Foundation
import UIKit

class FNCommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentsTextLabel: UILabel!
    @IBOutlet weak var timeTextLabel: UILabel!
    
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {}
    func setupLoading() {}
    
}
