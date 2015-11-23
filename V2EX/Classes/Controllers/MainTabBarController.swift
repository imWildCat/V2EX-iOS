//
//  MainTabBarController.swift
//  V2EX
//
//  Created by WildCat on 11/23/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        title = "V2EX"
        
        UITabBar.appearance().tintColor = UIColor(red:0.11, green:0.61, blue:0.96, alpha:1)
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if let itemTitle = item.title {
            switch itemTitle {
            case "发现":
                title = "V2EX"
            default:
                title = itemTitle
            }
        }
        
    }

}
