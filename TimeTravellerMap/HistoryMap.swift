//
//  HistoryMap.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import Foundation
import MapKit

class HistoryMap {
    
    var southWestCoordinate: CLLocationCoordinate2D
    var northEastCoordinate: CLLocationCoordinate2D
    var midCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake((southWestCoordinate.latitude + northEastCoordinate.latitude) / 2, (southWestCoordinate.longitude + northEastCoordinate.longitude) / 2)
    }
    var overlayBoudingMapRect: MKMapRect {
        get {
            let southWest = MKMapPointForCoordinate(southWestCoordinate)
            let northEast = MKMapPointForCoordinate(northEastCoordinate)
            return MKMapRectMake(northEast.x, southWest.y, fabs(northEast.x - southWest.x), fabs(northEast.y - southWest.y))
        }
    }
    
    init() {
        southWestCoordinate = CLLocationCoordinate2D(latitude: 40.712216, longitude: -74.22655)
        northEastCoordinate = CLLocationCoordinate2D(latitude: 40.773941, longitude: -74.12544)
    }
}
