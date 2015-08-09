//
//  UserIntroTableViewCell.swift
//  V2EX
//
//  Created by WildCat on 8/9/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserIntroTableViewCell: UITableViewCell {

    @IBOutlet weak var introLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
