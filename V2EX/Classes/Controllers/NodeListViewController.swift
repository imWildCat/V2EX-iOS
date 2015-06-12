//
//  NodeListViewController.swift
//  V2EX
//
//  Created by WildCat on 13/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit
//import Mustache21
import SwiftyJSON

class NodeListViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cats = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("default_nodes", ofType: "plist") ?? "") ?? NSArray()
        
//        var data =  NSDictionary(object: cats, forKey: "cats")
//        var data = ["cats" : cats]
        var jsonObj = JSON(cats)
        
        println(jsonObj.description)
        
        let bundle = NSBundle.mainBundle()
        let templatePath = bundle.pathForResource("node_list", ofType: "html")
        let templateHTML =  String(contentsOfFile: templatePath ?? "", encoding: NSUTF8StringEncoding, error: nil) ?? ""
//
//        let template = Template(string: templateHTML, error: nil)
        
//        let rendering = GRMustacheTemplate.renderObject(data, fromString: template, error: nil)
        
//        let rendering = template?.render(Box(data)) ?? "页面渲染失败。"
        let rendering = templateHTML.replace("{{data}}", withString: jsonObj.description)
        
        let path = NSBundle.mainBundle().bundlePath
        let baseURL = NSURL.fileURLWithPath(path) ?? NSURL()
        webView.loadHTMLString(rendering, baseURL: baseURL)
        
    }
    

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // TODO: use if let
        let url = request.URL

        if url?.scheme == "webview" {
            if let (action, params) = url?.URLString.parseWebViewAction() {
                if action == .OpenNode {
                    if let slug = params["slug"] {
                        presentTopicListViewController(slug)
                    }
                }
            }
            
            return false
        }
        
        
        return true
    }
    
    func presentTopicListViewController(nodeSlug: String?) {
        if let slug = nodeSlug {
            performSegueWithIdentifier("showTopicListVC", sender: slug)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicListVC" {
            let destinationViewController = segue.destinationViewController as! TopicListViewController
            destinationViewController.nodeSlug = sender as? String
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'");
    }
    
}
