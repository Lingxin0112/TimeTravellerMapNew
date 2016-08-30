//
//  Event+CoreDataProperties.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 18/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var area: String?
    @NSManaged var date: String?
    @NSManaged var eventDescription: String?
    @NSManaged var latitude: Double
    @NSManaged var longtitude: Double
    @NSManaged var name: String?
//    @NSManaged var otherURLs: String?
    @NSManaged var videoURL: String?
    @NSManaged var links: NSOrderedSet?

}
