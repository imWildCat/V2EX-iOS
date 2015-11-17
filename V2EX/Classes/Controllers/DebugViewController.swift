//
//  DebugViewController.swift
//  V2EX
//
//  Created by WildCat on 11/11/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {
    
    @IBOutlet weak var htmlTextView: UITextView!
    
    override func viewDidAppear(animated: Bool) {
        htmlTextView.text = MemoryCache.getLoginFailureHTML() ?? "尚无登录失败的情况。"
        htmlTextView.layer.borderWidth = 1.0
        htmlTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        htmlTextView.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AVAnalytics.beginLogPageView("DebugViewController")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AVAnalytics.endLogPageView("DebugViewController")
    }

}
