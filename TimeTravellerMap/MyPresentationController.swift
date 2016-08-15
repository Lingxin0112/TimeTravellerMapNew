//
//  MyPresentationController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 11/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class MyPresentationController: UIPresentationController {
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, atIndex: 0)
    }
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
