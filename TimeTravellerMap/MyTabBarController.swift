//
//  MyTabBarController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 10/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}
