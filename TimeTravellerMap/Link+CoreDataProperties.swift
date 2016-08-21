//
//  Link+CoreDataProperties.swift
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

extension Link {

    @NSManaged var address: String?
    @NSManaged var event: Event?

}
