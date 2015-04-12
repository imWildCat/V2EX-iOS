//
//  UserNotificationListCell.swift
//  V2EX
//
//  Created by WildCat on 29/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserNotificationListCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func render(viewModel: UserNotificationListCellViewModel) {
        avatarImageView.sd_setImageWithURL(("https:" + viewModel.avatarURI).toURL(), placeholderImage: UIImage(named: "node_icon"))
        
//        titleLabel.attributedText = viewModel.title
        titleLabel.text = viewModel.title
        
        timeLabel.text = viewModel.time
        
        contentLabel.text = viewModel.relatedContent ?? " "
//        if let content = viewModel.relatedContent {
//            contentLabel.text = content
//            contentLabel.hidden = false
//        } else {
//            contentLabel.hidden = true
//        }

        self.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
    }

}
