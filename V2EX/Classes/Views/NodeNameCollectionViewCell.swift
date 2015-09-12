//
//  NodeNameCollectionViewCell.swift
//  V2EX
//
//  Created by WildCat on 9/12/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class NodeNameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nodeNameLabel: UILabel!
    
    override var selected: Bool {
        didSet {
            if selected {
                backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
            } else {
                backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    override func awakeFromNib() {
        layer.cornerRadius = 12.5
        layer.masksToBounds = true
        
        layer.borderColor = UIColor(red:0.83, green:0.82, blue:0.81, alpha:1).CGColor
        layer.borderWidth = 1.0
    }
}
