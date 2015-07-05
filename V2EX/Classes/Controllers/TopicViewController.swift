//
//  TopicViewController.swift
//  V2EX
//
//  Created by WildCat on 15/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
//import WebKit

class TopicViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
//    var webView: WKWebView
    var topicId = 0

    required init(coder aDecoder: NSCoder) {
//        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        webView.backgroundColor = UIColor(red: 253/255, green: 248/255, blue: 234/255, alpha: 1)
        webView.opaque = false
        webView.delegate = self
        
//        view.addSubview(webView)
//        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
//        let widthConstraint = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
//        view.addConstraint(widthConstraint)
//        let heightConstraint = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
//        view.addConstraint(heightConstraint)
        
        requestTopic()
    }
    
    func requestTopic() {
        showProgressView()
        TopicSerivce.singleTopic(topicId, response: { [unowned self] (error, topic, replies)  in
            let path = NSBundle.mainBundle().bundlePath
            let baseURL = NSURL.fileURLWithPath(path)
            self.webView.loadHTMLString(TopicViewModel.renderHTML(topic, replies: replies), baseURL: baseURL)
            self.hideProgressView()
        })
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let scheme = request.URL?.scheme {
            if scheme == "file" {
                println(request.URLString)
                return true
            }
            
            if scheme == "webview" {
                println(request.URLString)
                return false
            }
        }
        
        
//        if let urlString = request.URL?.URLString {
//            if urlString.rangeOfString("https://cdn.v2ex.co") != nil || urlString.rangeOfString("http://cdn.v2ex.co") != nil {
//                return true
//            }
//        }
        
        return false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'");
    }
    
}
