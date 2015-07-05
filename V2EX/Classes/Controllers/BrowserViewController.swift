//
//  BrowserViewController.swift
//  V2EX
//
//  Created by WildCat on 6/13/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView
    var URL = ""

    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(webView)
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let widthConstraint = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraint(widthConstraint)
        let heightConstraint = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        view.addConstraint(heightConstraint)
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: URL)!))
    }

//    webView
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
