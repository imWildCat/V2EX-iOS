//
//  TFHppleExtension.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

extension TFHpple {
    convenience init(HTMLString: String) {
        self.init(HTMLData: HTMLString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true))
    }
    
    convenience init(HTMLObject: AnyObject?) {
        self.init(HTMLData: HTMLObject as NSData?)
    }
    
    
}

extension TFHppleElement {
    func searchFirst(xPath: String) -> TFHppleElement? {
        let ret = searchWithXPathQuery(xPath) as [TFHppleElement]
        if ret.count > 0 {
            return ret.first
        }
        return nil
    }
}