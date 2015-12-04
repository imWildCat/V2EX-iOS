//
//  Tab.swift
//  
//
//  Created by WildCat on 12/3/15.
//
//

import Foundation
import CoreData

class Tab: NSManagedObject {
    
    class func create() -> Tab {
        return Tab(entity: CoreDataStack.sharedStack.tabEntity, insertIntoManagedObjectContext: CoreDataStack.sharedStack.context)
    }
}

// MARK: Seeds

extension Tab {
    class func seed() {
        let request = NSFetchRequest()
        let stack = CoreDataStack.sharedStack
        request.entity = stack.tabEntity
        
        var error: NSError?
        let count = stack.context.countForFetchRequest(request, error: &error)
        if error == nil {
            print("Count is \(count)")
        } else {
            print(error)
        }
    }
}
