//
//  TopicListViewController.swift
//  V2EX
//
//  Created by WildCat on 17/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

class TopicListViewController: UITableViewController {
    
    override func viewDidAppear(animated: Bool) {
        println("appear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        println("disappear")
    }
    
    override func viewDidLoad() {
        println("load")
    }

}
