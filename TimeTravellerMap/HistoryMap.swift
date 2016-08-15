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
    var midCoordinate: CLLocationCoordinate2D
    var image: UIImage
//    var midCoordinate: CLLocationCoordinate2D {
//        get {
//            return CLLocationCoordinate2DMake((southWestCoordinate.latitude + northEastCoordinate.latitude) / 2, (southWestCoordinate.longitude + northEastCoordinate.longitude) / 2)
//        }
//    }
    
//    var midCoordinate: CLLocationCoordinate2D {
//        return CLLocationCoordinate2DMake(40.72422, 74.172574)
//    }
//    var overlayBoudingMapRect: MKMapRect {
//        get {
//            let southWest = MKMapPointForCoordinate(southWestCoordinate)
//            let northEast = MKMapPointForCoordinate(northEastCoordinate)
////            let originCoordinate = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: 40.772216, longitude: -74.22544))
////            let origin = MKCoordinateForMapPoint(originCoordinate)
////            return MKMapRectMake(northEast.x, southWest.y, fabs(northEast.x - southWest.x), fabs(northEast.y - southWest.y))
//            return MKMapRectMake(southWest.x, northEast.y, fabs(northEast.x - southWest.x), fabs(northEast.y - southWest.y))
//        }
//
//    }
    
    var overlayBoudingMapRect: MKMapRect
    
    init() {
        southWestCoordinate = CLLocationCoordinate2D(latitude: 40.712216, longitude: -74.22655)
        northEastCoordinate = CLLocationCoordinate2D(latitude: 40.773941, longitude: -74.12544)
        midCoordinate = CLLocationCoordinate2DMake((southWestCoordinate.latitude + northEastCoordinate.latitude) / 2, (southWestCoordinate.longitude + northEastCoordinate.longitude) / 2)
        
        let southWest = MKMapPointForCoordinate(southWestCoordinate)
        let northEast = MKMapPointForCoordinate(northEastCoordinate)
        overlayBoudingMapRect =  MKMapRectMake(southWest.x, northEast.y, fabs(northEast.x - southWest.x), fabs(northEast.y - southWest.y))
        image = UIImage()
    }
    
    init(map: Map) {
        southWestCoordinate = CLLocationCoordinate2D(latitude: Double(map.swLatitude!), longitude: Double(map.swLongtitude!))
        northEastCoordinate = CLLocationCoordinate2D(latitude: Double(map.neLatitude!), longitude: Double(map.neLongtitude!))
        midCoordinate = CLLocationCoordinate2DMake((southWestCoordinate.latitude + northEastCoordinate.latitude) / 2, (southWestCoordinate.longitude + northEastCoordinate.longitude) / 2)
        
        let southWest = MKMapPointForCoordinate(southWestCoordinate)
        let northEast = MKMapPointForCoordinate(northEastCoordinate)
        overlayBoudingMapRect =  MKMapRectMake(southWest.x, northEast.y, fabs(northEast.x - southWest.x), fabs(northEast.y - southWest.y))
        image = UIImage(data: map.mapImageData!)!
    }
    
}
