//
//  UIViewController+CoreDataStack.swift
//  V2EX
//
//  Created by WildCat on 12/3/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

extension UIViewController {
    
    var coreDataStack: CoreDataStack {
        get {
            return CoreDataStack.sharedStack
        }
    }
    
}