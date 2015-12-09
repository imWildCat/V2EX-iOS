//
//  CustomActivity.swift
//  V2EX
//
//  Created by WildCat on 8/17/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class CustomActivity: UIActivity {
    
    let title: String
    let image: UIImage
    var perform: () -> Void
    
    init(title: String, image: UIImage, perform: (() -> Void)) {
        self.title = title
        self.image = image
        self.perform = perform
        
        super.init()
    }
    
    override func activityTitle() -> String? {
        return title
    }
    
    override func activityImage() -> UIImage? {
        return image
    }
    
    override func activityType() -> String? {
        return CustomActivity.self.description() + ":" + title
    }
    
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Action
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override func performActivity() {
        perform()
        activityDidFinish(true)
    }
}