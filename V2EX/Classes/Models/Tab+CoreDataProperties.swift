//
//  Tab+CoreDataProperties.swift
//  V2EX
//
//  Created by WildCat on 12/6/15.
//  Copyright © 2015 WildCat. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tab {

    @NSManaged var name: String
    @NSManaged var priority: NSNumber
    @NSManaged var slug: String
    @NSManaged var enabled: Bool

}
