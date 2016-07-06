//
//  InformationAnnotationView.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 05/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class InformationAnnotationView: MKAnnotationView {
    // Required for MKAnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when drawing the InformationAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let informationAnnotation = self.annotation as! InformationAnnotation
    }
}
