//
//  Map.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 21/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Map: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    func getMapRegion() -> MKCoordinateRegion{
        let overlayRect = self.mapRect
        let region = MKCoordinateRegionForMapRect(overlayRect)
        return region
    }
    
    var midCoordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake((Double(neLatitude!) + Double(swLatitude!)) / 2, (Double(swLongtitude!) + Double(neLongtitude!)) / 2)
        }
    }
    
    var mapRect: MKMapRect {
        get {
            let northEastCoordinate = CLLocationCoordinate2D(latitude: Double(self.neLatitude!), longitude: Double(self.neLongtitude!))
            let southWestCoordinate = CLLocationCoordinate2D(latitude: Double(self.swLatitude!), longitude: Double(self.swLongtitude!))
            
            let southWestPoint = MKMapPointForCoordinate(southWestCoordinate)
            let northEastPoint = MKMapPointForCoordinate(northEastCoordinate)
            
            let mapRect =  MKMapRectMake(southWestPoint.x, northEastPoint.y, fabs(northEastPoint.x - southWestPoint.x), fabs(northEastPoint.y - southWestPoint.y))
            return mapRect
        }
    }
}
