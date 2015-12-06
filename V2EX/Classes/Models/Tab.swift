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

extension Tab: CustomDebugStringConvertible {
    override var debugDescription: String {
        return "<V2EX.Tab> (name: \(name), slug:\(slug), priority: \(priority), enabled: \(enabled))"
    }
}

// MARK: Seeds

extension Tab {
    static func seed() {
        let request = NSFetchRequest()
        let stack = CoreDataStack.sharedStack
        request.entity = stack.tabEntity
        
        var error: NSError?
        let count = stack.context.countForFetchRequest(request, error: &error)
        if error == nil {
            if count == 0 {
                let tabData = [
                    ("全部", "all"),
                    ("最热", "hot"),
                    ("R2", "r2"),
                    ("问与答", "qna"),
                    ("技术", "tech"),
                    ("创意", "creative"),
                    ("好玩", "play"),
                    ("Apple", "apple"),
                    ("酷工作", "jobs"),
                    ("交易", "deals"),
                    ("城市", "city"),
                ]
                
                var priority = 0
                for data in tabData {
                    let newTab = self.create()
                    newTab.name = data.0
                    newTab.slug = data.1
                    newTab.enabled = true
                    newTab.priority = priority
                    priority += 1
                }
                
                CoreDataStack.sharedStack.saveMainContext() // FIX: Block main thread
            } else {
                do {
                    let fetchRequest = NSFetchRequest(entityName: "Tab")
                    let tabs = try CoreDataStack.sharedStack.context.executeFetchRequest(fetchRequest) as! [Tab]
                    print(tabs)
                } catch let error as NSError {
                    print("error: \(error.localizedDescription)")
                }
                
                
            }
        } else {
            print(error)
        }
    }
}

// MARK: Fetching

extension Tab {
    static func fetchSortedList() throws -> [Tab] {
        let fetchRequest = NSFetchRequest(entityName: "Tab")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "priority", ascending: true)
        ]
        return try CoreDataStack.sharedStack.context.executeFetchRequest(fetchRequest) as! [Tab]
    }
}
