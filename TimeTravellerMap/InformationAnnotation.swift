//
//  InformationAnnotation.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 05/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class InformationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var videoURL: String?
    var otherURLs: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, url: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.videoURL = url
    }
    
    init(event: Event) {
        self.coordinate = event.coordinate
        self.title = event.name
        self.subtitle = event.date
        self.videoURL = event.videoURL
        self.otherURLs = event.otherURLs
    }
}
