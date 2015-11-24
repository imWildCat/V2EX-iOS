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
    
    var discoveryViewController: UIViewController!
    lazy var nodeListViewController: NodeListCollectionViewController = self.storyboard!.instantiateViewControllerWithIdentifier("nodeListVC") as! NodeListCollectionViewController
    lazy var userViewController: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("userVC") 
    lazy var preferenceViewController: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("preferenceVC")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discoveryViewController = viewControllers[0] 
        sharedDiscoveryViewController = discoveryViewController as? DiscoveryViewController
        
        // Render node list
        nodeListViewController.nibName // FIXME: Do not know this line of code
        
        
    }

    class func sharedDiscoveryVC() -> DiscoveryViewController? {
        return sharedDiscoveryViewController
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
