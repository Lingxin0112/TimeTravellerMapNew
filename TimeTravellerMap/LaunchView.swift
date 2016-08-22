//
//  LaunchView.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 20/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class LaunchView: UIView {

    var text = ""
    
    class func launchView(view: UIView, animated: Bool) -> LaunchView {
        let launchView = LaunchView(frame: view.bounds)
        launchView.opaque = false

//        view.addSubview(launchView)
//        view.userInteractionEnabled = false
        launchView.loading()
        return launchView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    override func drawRect(rect: CGRect) {
//        let width: CGFloat = 96
//        let height: CGFloat = 96
//        
//        let rect = CGRect(x: round((bounds.size.width - width) / 2),
//                          y: round((bounds.size.height - height) / 2),
//                          width: width,
//                          height: height)
//        
//        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 10)
//        UIColor(white: 0.3, alpha: 0.8).setFill()
//        roundedRect.fill()
//        
//        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(16),
//                          NSForegroundColorAttributeName: UIColor.whiteColor()]
//        let textSize = text.sizeWithAttributes(attributes)
//        
//        let textPoint = CGPoint(x: center.x - round(textSize.width / 2),
//                                y: center.y - round(textSize.height / 2))
//        text.drawAtPoint(textPoint, withAttributes: attributes)
//    }
    

    
    func loading() {
        let image = UIImage(named: "man-walking")
        let imageView = UIImageView(image: image!)
        
        imageView.frame = CGRect(x: -20, y: self.bounds.height/2 - 20,
                                 width: 40, height: 40)
        self.addSubview(imageView)
        
        let leftLabel = UILabel()
        leftLabel.frame = CGRect(origin: CGPoint(x: 0, y: self.center.y + 20), size: CGSize(width: 40, height: 20))
        leftLabel.text = "1800"
        leftLabel.backgroundColor = UIColor.redColor()
        leftLabel.textAlignment = .Center
        self.addSubview(leftLabel)
        
        let rightLabel = UILabel()
        rightLabel.frame = CGRect(origin: CGPoint(x: self.bounds.width - 40, y: self.center.y + 20), size: CGSize(width: 40, height: 20))
        rightLabel.text = "2016"
        rightLabel.backgroundColor = UIColor.redColor()
        rightLabel.textAlignment = .Center
        self.addSubview(rightLabel)
        
        UIView.animateWithDuration(2, animations: { _ in
                imageView.center.x += self.bounds.width
            }, completion: { _ in
                self.removeFromSuperview()
        })
//        imageView.frame = self.bounds
        
    }
}
