//
//  TopicTitleCell.swift
//  V2EX
//
//  Created by WildCat on 09/01/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class TopicTitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    func render(viewModel: TopicTitleCellViewModel) {
        titleLabel.text = viewModel.title
    }

    

}
