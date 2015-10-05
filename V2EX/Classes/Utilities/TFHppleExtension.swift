//
//  TFHppleExtension.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation
import hpple

extension TFHpple {
    convenience init(HTMLString: String) {
        self.init(HTMLData: HTMLString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true))
    }
    
    convenience init(HTMLStringOptional: String?) {
        self.init(HTMLString: HTMLStringOptional ?? "")
    }
    
    convenience init(HTMLObject: AnyObject?) {
        self.init(HTMLData: HTMLObject as? NSData)
    }
    
    func searchFirst(xPath: String) -> TFHppleElement? {
        let ret = searchWithXPathQuery(xPath) as! [TFHppleElement]
        if ret.count > 0 {
            return ret.first
        }
        return nil
    }
    
    func searchElements(xPath: String) -> [TFHppleElement] {
         return searchWithXPathQuery(xPath) as! [TFHppleElement]
    }
    
}

extension TFHppleElement {
    func searchFirst(xPath: String) -> TFHppleElement? {
        let ret = searchWithXPathQuery(xPath) as! [TFHppleElement]
        if ret.count > 0 {
            return ret.first
        }
        return nil
    }
    
    func attr(name: String) -> String? {
        return self[name] as? String
    }
}