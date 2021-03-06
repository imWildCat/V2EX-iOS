//
//  HMSegmentedControlExtension.swift
//  V2EX
//
//  Created by WildCat on 13/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit
import HMSegmentedControl

extension HMSegmentedControl {

//    public override func prepareForInterfaceBuilder() {
//        setUp()
//    }
    
    func setUp() {
        // Set up tabSegmentedControl
        selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        selectionIndicatorColor = UIColor(red: 0.91, green: 0.3, blue: 0.24, alpha: 1)
        selectionIndicatorHeight = 3.0
        selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        backgroundColor = UIColor(red:0.91, green:0.94, blue:0.95, alpha:1)
        titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(16)
        ]
            // UIColor(red: 253/255, green: 248/255, blue: 234/255, alpha: 1)
    }
}

//

//
class IB_HMSegmentedControl: HMSegmentedControl {
    
}
