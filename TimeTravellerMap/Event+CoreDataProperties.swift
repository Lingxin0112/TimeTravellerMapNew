//
//  Event+CoreDataProperties.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 13/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var date: NSDate?
    @NSManaged var eventDescription: String?
    @NSManaged var videoLink: String?
    @NSManaged var area: String?
    @NSManaged var name: String?
    @NSManaged var link: NSSet?
    @NSManaged var location: Location?

}
