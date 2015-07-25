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
    var topic: Topic? // If topic is not nil, do not start a request to load topic

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
        let path = NSBundle.mainBundle().bundlePath
        let baseURL = NSURL.fileURLWithPath(path)
        
        if let newTopic = topic {
            webView.loadHTMLString(TopicViewModel.renderHTML(newTopic, replies: []), baseURL: baseURL)
            hideProgressView()
            return
        }
        
        showProgressView()
        TopicSerivce.singleTopic(topicId, response: { [unowned self] (error, fetchedTopic, replies)  in
            self.webView.loadHTMLString(TopicViewModel.renderHTML(fetchedTopic, replies: replies), baseURL: baseURL)
            self.hideProgressView()
        })
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let scheme = request.URL?.scheme {
            println(request.URLString)

            if scheme == "file" {
                return true
            }
            
            if scheme == "webview" {
                actionHanlder(request.URLString)
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
    
    func actionHanlder(URL: String) {
        let (action, params) = URL.parseWebViewAction()
        switch action {
        case .OpenBrowser:
            openWebBrowser(params["url"])
        case .User:
            userDidClick(params["username"])
        default:
            break
        }
    }
    
    func openWebBrowser(URL: String?) {
        if let wrappedURL = URL, browserVC = storyboard?.instantiateViewControllerWithIdentifier("browserVC") as? BrowserViewController {
            browserVC.URL = wrappedURL
            navigationController?.pushViewController(browserVC, animated: true)
        }
    }
    
    func userDidClick(username: String?) {
        if let name = username {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let atUserButton = UIAlertAction(title: "@\(name)", style: .Default) {
                [unowned self, unowned alert] action in
                print("OK Pressed")
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let viewUserButton = UIAlertAction(title: "查看资料", style: .Default) {
                [unowned self, unowned alert] action in
                print("OK Pressed")
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
        
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel) {
                [unowned self, unowned alert] action in
                print("OK Pressed")
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'");
    }
    
}
