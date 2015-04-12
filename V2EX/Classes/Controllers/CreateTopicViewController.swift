//
//  CreateTopicViewController.swift
//  V2EX
//
//  Created by WildCat on 12/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class CreateTopicViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    var nodeSlug: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "close_icon")
        
        let button = UIBarButtonItem(image: image, style: .Plain, target: self, action: Selector("close"))
        navItem.leftBarButtonItem = button
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func close() {
        dismissSelf()
    }
    
    func dismissSelf() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
