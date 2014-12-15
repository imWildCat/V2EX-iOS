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
        
        avatarImageView.setImageWithURL(NSURL(string: "https:" + viewModel.avatarURI), placeholderImage: UIImage(named: "node_icon"))
        
        titleLabel.text = viewModel.title
        
        authorLabel.text = viewModel.authorName
        
        if let nodeName = viewModel.nodeName {
            nodeNameLabel.text = nodeName
        } else {
            nodeNameContainer.hidden = true
        }
        
        timeLabel.text = viewModel.time
        
        replyCountLabel.text = viewModel.repliesCount
    }
}
