//
//  HudView.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 14/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

@IBDesignable class HudView: UIView {
    @IBInspectable var text = ""
    
    class func hudInView(view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.opaque = false
        
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        hudView.showAnimated(animated)
        return hudView
    }
    
    override func drawRect(rect: CGRect) {
        let width: CGFloat = 96
        let height: CGFloat = 96
        
        let rect = CGRect(x: round((bounds.size.width - width) / 2),
                          y: round((bounds.size.height - height) / 2),
                          width: width,
                          height: height)
        
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(16),
                          NSForegroundColorAttributeName: UIColor.whiteColor()]
        let textSize = text.sizeWithAttributes(attributes)
        
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2),
                                y: center.y - round(textSize.height / 2))
        text.drawAtPoint(textPoint, withAttributes: attributes)
    }
    
    func showAnimated(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: { 
                self.alpha = 1
                self.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
}
