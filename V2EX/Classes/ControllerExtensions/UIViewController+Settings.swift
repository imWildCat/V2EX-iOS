//
//  UIViewController+Settings.swift
//  V2EX
//
//  Created by WildCat on 12/1/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

private let TOPIC_CONTENT_FONT_SIZE = "topic_content_font_size"
private let BACKGROUND_FETCH = "should_do_background_fetch"

extension UIViewController {
    
    // MARK: Font size of topic content
    class var topicFontSizeSetting: TopicFontSize {
        get {
            let size = NSUserDefaults.standardUserDefaults().stringForKey(TOPIC_CONTENT_FONT_SIZE) ?? "normal"
            return TopicFontSize(string: size)
        }
        
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue.cssClassName, forKey: TOPIC_CONTENT_FONT_SIZE)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: Background fetch
    class var shouldPeformBackgroundFetch: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(BACKGROUND_FETCH)
        }
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: BACKGROUND_FETCH)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}