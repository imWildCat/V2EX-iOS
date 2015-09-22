//
//  AnimationHelper.swift
//  V2EX
//
//  Created by WildCat on 8/13/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

private let delay = 0.0

struct AnimationHelper {
    
    static func spring(duration: NSTimeInterval, animations: (() -> Void)!) {
            UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .TransitionNone, animations: {
                
                animations()
                
                }, completion: { finished in
                    
            })
    }
}