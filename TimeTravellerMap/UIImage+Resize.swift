//
//  UIImage+Resize.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 31/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImageSize(bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
