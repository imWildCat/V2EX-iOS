//
//  UserTopicTableViewCell.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserTopicTableViewCell: UITableViewCell {

    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var nodeNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    
    
    func render(viewModel: UserTopicListCellViewModel) {
        topicTitleLabel.text = viewModel.topicTitle
        nodeNameLabel.text = viewModel.nodeName
        timeLabel.text = viewModel.time
        replyCountLabel.text = viewModel.replyCount
    }

}
