//
//  Tab+CoreDataProperties.swift
//  
//
//  Created by WildCat on 12/3/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tab {

    @NSManaged var name: String
    @NSManaged var slug: String
    @NSManaged var priority: NSNumber

}
