//
//  HistoryMapOverlayView.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class HistoryMapOverlayView: MKOverlayRenderer {
    var overlayImage: UIImage {
        didSet {
            setNeedsDisplay()
        }
    }
    var overlayRect: CGRect {
        return rectForMapRect(overlay.boundingMapRect)
    }
    
    init(overlay: MKOverlay, overlayImage: UIImage) {
        self.overlayImage = overlayImage
        super.init(overlay: overlay)
    }
    
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
    
        let imageReference = overlayImage.CGImage
        let theMapRect = overlay.boundingMapRect
        let theRect = rectForMapRect(theMapRect)
        
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextTranslateCTM(context, 0.0, -theRect.size.height)
        CGContextDrawImage(context, theRect, imageReference)
    }
    
}
