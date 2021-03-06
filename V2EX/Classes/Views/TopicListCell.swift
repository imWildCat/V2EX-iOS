//
//  TopicListCell.swift
//  V2EX
//
//  Created by WildCat on 17/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

class TopicListCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var nodeNameContainer: UIView!
    @IBOutlet weak var nodeNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    
    func render(viewModel: TopicListCellViewModel) {
        
        avatarImageView.sd_setImageWithURL(("https:" + viewModel.avatarURI).toURL(), placeholderImage: UIImage(named: "avatar_placeholder"))
        
        titleLabel.text = viewModel.title
        
        authorLabel.text = viewModel.authorName
        
        if viewModel.nodeName.isEmpty {
            nodeNameContainer.hidden = true
        } else {
            nodeNameLabel.text = viewModel.nodeName
        }
        
        timeLabel.text = viewModel.time
        
        replyCountLabel.text = viewModel.repliesCount
    }
}
