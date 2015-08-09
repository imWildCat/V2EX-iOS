//
//  UserInfoTableViewCell.swift
//  V2EX
//
//  Created by WildCat on 8/9/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var infoView: UserInfoView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
