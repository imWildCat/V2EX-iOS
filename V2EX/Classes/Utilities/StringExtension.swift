//
//  StringExtension.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

extension String {
    
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func replace(pattern pattern: String, withString: String) -> String {
        let stringlength = self.characters.count
        let regex:NSRegularExpression = try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        return regex.stringByReplacingMatchesInString(self, options: [], range: NSMakeRange(0, stringlength), withTemplate: withString)
    }
    
    // Inspired by Ruby
    
    func scan(pattern: String, error: NSErrorPointer = nil) -> [String] {
        let re = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = re.matchesInString(self, options: [], range: NSRange(location: 0, length: self.utf16.count)) 
        var strings = [String]()
        for m in matches {
            if m.numberOfRanges > 0 {
                let substring = (self as NSString).substringWithRange(m.rangeAtIndex(0))
                strings.append(substring)
            }
        }
        return strings
    }
    
    func match(pattern: String) -> [String]? {
//        let error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        let re = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = re.matchesInString(self, options: [], range: NSRange(location: 0, length: self.utf16.count)) 
        var firstMatchedResults = [String]()
        for m in matches {
            if m.numberOfRanges > 0 {
                for i in 0 ... m.numberOfRanges - 1 {
                    let substring = (self as NSString).substringWithRange(m.rangeAtIndex(i))
                    firstMatchedResults.append(substring)
                }
            }
        }
        if matches.count == 0 {
            return nil
        } else {
            return firstMatchedResults
        }
    }
    
    func toURL() -> NSURL {
        if let url = NSURL(string: self) {
            return url
        }
        NSLog("Bad URL(in String Extension): " + self)
        return NSURL()
    }
    
    func strippingHTML() -> String? {
        var scanner: NSScanner
        var html: NSString = self
        var text: NSString? = nil
        scanner = NSScanner(string: html as String)
        
        while scanner.atEnd == false {
            scanner.scanUpToString("<", intoString: nil)
            
            scanner.scanUpToString(">", intoString: &text)
            
            html = html.stringByReplacingOccurrencesOfString("\(text!)>", withString: "")
        }
        
        html = html.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return html as String
    }
    
    
    /**
    Parse URL request string from WebView(must start with "webview://")
    eg. webview://open_node?slug=v2ex
    
    - returns: (action: WebViewAction, params: [String: String])
    */
    func parseWebViewAction() -> (WebViewAction, [String: String]) {
        var params = [String: String]()
        
        let parts = self.componentsSeparatedByString("?")
        if let queryString = parts.last {
            let queryElements = queryString.componentsSeparatedByString("&")
            for element in queryElements {
                let keyAndValue = element.componentsSeparatedByString("=")
                if keyAndValue.count > 0 {
                    if let key = keyAndValue.first {
                        let value = keyAndValue.last
                        params[key] = value
                    }
                }
            }
        }
        // Fix: URL with params
        let url = self.match("\\?url=(.+)")?[1] ?? ""
        params["url"] = url
        
        let actionString = self.match("webview://(\\w+)\\?")?[1] ?? ""
        
        
        var action: WebViewAction = .None
        switch actionString {
        case "open_node":
            action = .OpenNode
        case "open_browser":
            action = .OpenBrowser
        case "show_topic":
            action = .ShowTopic
        case "show_member":
            action = .User
        case "show_image":
            action = .ShowImage
        case "show_post_actions":
            action = .ShowPostActions
        default:
            action = .None
        }
        
        return (action, params)
    }
}