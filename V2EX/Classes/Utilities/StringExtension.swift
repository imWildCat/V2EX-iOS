//
//  StringExtension.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

extension String {
    // Inspired by Ruby
    
    func scan(pattern: String, options: NSRegularExpressionOptions = nil, error: NSErrorPointer = nil) -> [String] {
        let re = NSRegularExpression(pattern: pattern, options: nil, error: nil)!
        let matches = re.matchesInString(self, options: nil, range: NSRange(location: 0, length: self.utf16Count)) as [NSTextCheckingResult]
        var strings = [String]()
        for m in matches {
            if m.numberOfRanges > 0 {
                let substring = (self as NSString).substringWithRange(m.rangeAtIndex(0))
                strings.append(substring)
            }
        }
        return strings
    }
    
    func match(pattern: String, options: NSRegularExpressionOptions = nil, error: NSErrorPointer = nil) -> [String]? {
        let re = NSRegularExpression(pattern: pattern, options: nil, error: nil)!
        let matches = re.matchesInString(self, options: nil, range: NSRange(location: 0, length: self.utf16Count)) as [NSTextCheckingResult]
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
}