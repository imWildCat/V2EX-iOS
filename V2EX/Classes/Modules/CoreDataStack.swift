//
//  CoreDataStack.swift
//  V2EX
//
//  Created by WildCat on 12/3/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: NSObject {
    static let moduleName = "V2EX"
    static let sharedStack = CoreDataStack()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let persistentStoreURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(moduleName).sqlite")
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: persistentStoreURL,
                options: [NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: false])
        } catch {
            fatalError("Persistent store error! \(error)")
        }
        
        return coordinator
    }()
    
    private lazy var saveManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
    }()
    
    lazy var context: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.saveManagedObjectContext
        return managedObjectContext
    }()
    
    func saveMainContext() {
        guard context.hasChanges || saveManagedObjectContext.hasChanges else {
            return
        }
        
        context.performBlockAndWait() {
            do {
                try self.context.save()
            } catch {
                fatalError("Error saving main managed object context! \(error)")
            }
        }
        
        saveManagedObjectContext.performBlock() {
            do {
                try self.saveManagedObjectContext.save()
            } catch {
                fatalError("Error saving private managed object context! \(error)")
            }
        }
    }
    
    // MARK: Entities
    lazy var tabEntity: NSEntityDescription = {
        if let tabEntity = NSEntityDescription.entityForName("Tab", inManagedObjectContext: self.context) {
            return tabEntity
        }
        fatalError("Could not find entity descriptions!")
    }()
}

// MARK: Factories to make new model instance
extension CoreDataStack {
    
}