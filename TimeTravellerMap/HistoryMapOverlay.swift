//
//  MapOverlay.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class HistoryMapOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(historyMap: HistoryMap) {
        coordinate = historyMap.midCoordinate
        boundingMapRect = historyMap.overlayBoudingMapRect
    }
}
