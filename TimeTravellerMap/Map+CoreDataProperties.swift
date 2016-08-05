//
//  Map+CoreDataProperties.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 04/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Map {

    @NSManaged var area: String?
    @NSManaged var era: String?
    @NSManaged var mapImageData: NSData?
    @NSManaged var name: String?
    @NSManaged var neLatitude: NSNumber?
    @NSManaged var neLongtitude: NSNumber?
    @NSManaged var swLatitude: NSNumber?
    @NSManaged var swLongtitude: NSNumber?
    @NSManaged var year: NSNumber?
    @NSManaged var comment: String?

}
