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
        let historyMap = HistoryMap(map: self)
        let mapOverlay = HistoryMapOverlay(historyMap: historyMap)
        let overlayRect = mapOverlay.boundingMapRect
        let region = MKCoordinateRegionForMapRect(overlayRect)
        return region
    }
    
    var midCoordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake((Double(neLatitude!) + Double(swLatitude!)) / 2, (Double(swLongtitude!) + Double(neLongtitude!)) / 2)
        }
    }
}
