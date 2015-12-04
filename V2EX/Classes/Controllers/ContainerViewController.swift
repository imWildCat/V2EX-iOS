//
//  ContainerViewController.swift
//  V2EX
//
//  Created by WildCat on 11/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

private var sharedDiscoveryViewController: DiscoveryViewController?

class ContainerViewController: UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    class func sharedDiscoveryVC() -> DiscoveryViewController? {
        return sharedDiscoveryViewController
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
