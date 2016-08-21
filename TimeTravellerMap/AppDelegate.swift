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
//        loadHistoryMap()
        
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
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "Launch")
        
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
    
    func loadHistoryMap() {
        let entity = NSEntityDescription.entityForName("Map", inManagedObjectContext: coreDataStack.context)
        let map1 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map1.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-9ad")!)
        map1.name = "Test1"
        map1.area = "Sheffield"
        map1.era = "ad"
        map1.year = 9
        map1.neLatitude = 53.3861958137369
        map1.neLongtitude = -1.46166889892051
        map1.swLatitude = 53.3781495132825
        map1.swLongtitude = -1.47853110107949
        
        let map2 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map2.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
        map2.name = "Test2"
        map2.area = "Sheffield"
        map2.era = "bc"
        map2.year = -86
        map2.neLatitude = 53.3861958137369
        map2.neLongtitude = -1.46166889892051
        map2.swLatitude = 53.3781495132825
        map2.swLongtitude = -1.47853110107949
        
        let map3 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map3.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-116ad")!)
        map3.name = "Test3"
        map3.area = "Sheffield"
        map3.era = "ad"
        map3.year = 116
        map3.neLatitude = 53.3861958137369
        map3.neLongtitude = -1.46166889892051
        map3.swLatitude = 53.3781495132825
        map3.swLongtitude = -1.47853110107949
        
        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-214bc")!)
        map4.name = "Test4"
        map4.area = "Sheffield"
        map4.era = "bc"
        map4.year = -214
        map4.neLatitude = 53.3861958137369
        map4.neLongtitude = -1.46166889892051
        map4.swLatitude = 53.3781495132825
        map4.swLongtitude = -1.47853110107949
        
        let map5 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map5.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-269ad")!)
        map5.name = "Test5"
        map5.area = "Sheffield"
        map5.era = "ad"
        map5.year = 269
        map5.neLatitude = 53.3861958137369
        map5.neLongtitude = -1.46166889892051
        map5.swLatitude = 53.3781495132825
        map5.swLongtitude = -1.47853110107949
        
        let map6 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map6.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-279bc")!)
        map6.name = "Test6"
        map6.area = "Sheffield"
        map6.era = "bc"
        map6.year = -279
        map6.neLatitude = 53.3861958137369
        map6.neLongtitude = -1.46166889892051
        map6.swLatitude = 53.3781495132825
        map6.swLongtitude = -1.47853110107949
        
        do {
            try coreDataStack.context.save()
        } catch {
            fatalError("Error: \(error)")
        }
    }

}

