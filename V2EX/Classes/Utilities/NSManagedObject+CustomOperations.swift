//
//  NSManagedObject+CustomOperations.swift
//  V2EX
//
//  Created by WildCat on 12/4/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    func save() {
        CoreDataStack.sharedStack.saveMainContext()
    }
    
}