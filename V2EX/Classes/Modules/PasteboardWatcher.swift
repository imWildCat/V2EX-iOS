//
//  PasteboardWatcher.swift
//  V2EX
//
//  Created by WildCat on 11/8/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

class PasteboardWatcher {
    
    // Flag to detect if the URL has been already handled before
    static var lastURLJumped = ""
    
    class func watch() {
        if let string = UIPasteboard.generalPasteboard().string {
            handleV2EXLink(string)
        }
    }
    
    class func handleV2EXLink(content: String) {
        if content == lastURLJumped {
            return
        }
        if let _ = content.lowercaseString.rangeOfString("v2ex.com/") {
            if let topicIDString = content.match("v2ex.com/t/(\\d+)")?[1], topicID = Int(topicIDString) {
                showAlertForPasteboardLink(content, type: .Topic) {
                    UIViewController.topViewContrller().showTopicVC(topicID)
                    lastURLJumped = content
                }
            } else if let nodeSlugString = content.match("v2ex.com/go/(\\w+)")?[1] {
                showAlertForPasteboardLink(content, type: .Node) {
                    UIViewController.topViewContrller().showNodeVC(nodeSlugString)
                    lastURLJumped = content
                }
            }
        }
    }
    
    enum PasteboardAlertType {
        case Topic
        case Node
    }
    
    class func showAlertForPasteboardLink(link: String, type: PasteboardAlertType, okActionCallback: () -> ()) {
        var pageName = "话题"
        if type == .Node {
            pageName = "节点"
        }
        let alert = UIAlertController(title: "是否跳转到相关页面？", message: "您已复制\n \(link) \n是否需要跳转到这个\(pageName)？", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "不用", style: .Cancel) { (action) -> Void in
            
        }
        let okAction = UIAlertAction(title: "好", style: .Default) { (action) -> Void in
            okActionCallback()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        UIViewController.topViewContrller().presentViewController(alert, animated: true, completion: nil)
    }
}