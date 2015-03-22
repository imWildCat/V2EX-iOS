//
//  UserReplyListTableViewCell.swift
//  V2EX
//
//  Created by WildCat on 22/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserReplyListTableViewCell: UITableViewCell {
    @IBOutlet weak var replyContentLabel: UILabel!
    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func render(viewModel: UserReplyListCellViewModel) {
        replyContentLabel.text = viewModel.replyContent
        topicTitleLabel.text = viewModel.topicTitle
        authorNameLabel.text = viewModel.authorName
        timeLabel.text = viewModel.time
    }

}
