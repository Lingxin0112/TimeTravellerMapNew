//
//  AppDelegate.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        customizeAppearace()
        
        // Override point for customization after application launch.
        
//        // save test event
//        let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: coreDataStack.context) as! Event
//        event.area = "Sheffield"
//        
//        do {
//            try coreDataStack.context.save()
//        } catch let error as NSError{
//            print("Saving error: \(error.localizedDescription)")
//        }
//        
//        // retrieve test event
//        var events: [Event]!
//        do {
//            let request = NSFetchRequest(entityName: "Event")
//            events = try coreDataStack.context.executeFetchRequest(request) as! [Event]
//        } catch let error as NSError{
//            print("Fetching error: \(error.localizedDescription)")
//        }
        
        let tabBarController = window?.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            let mapNavigationController = tabBarViewControllers[0] as! UINavigationController
            let mapViewController = mapNavigationController.topViewController as! MapViewController
            mapViewController.managedContext = coreDataStack.context
            
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let eventTableViewController = navigationController.topViewController as! EventTableViewController
            eventTableViewController.managedContext = coreDataStack.context
            let _ = eventTableViewController.view
            
            let nvController = tabBarViewControllers[2] as! UINavigationController
            let mapsTableViewController = nvController.topViewController as! MapsTableViewController
            mapsTableViewController.managedContext = coreDataStack.context
            let _ = mapsTableViewController.view
            
            //        eventTableViewController.events = events
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func customizeAppearace() {
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UITabBar.appearance().barTintColor = UIColor.blackColor()
    }

}

