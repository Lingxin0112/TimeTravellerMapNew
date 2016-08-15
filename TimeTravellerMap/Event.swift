//
//  Event.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 16/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class Event: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longtitude)
    }
    
    var sectionIdentifier: String {
        return "area"
    }
    
    func isInThisArea(visibleRect: MKMapRect) -> Bool {
        let coordinate = CLLocationCoordinate2D(latitude: Double(self.latitude), longitude: Double(self.longtitude))
        let point = MKMapPointForCoordinate(coordinate)
        if MKMapRectContainsPoint(visibleRect, point) {
            return true
        }
        return false
    }
}
