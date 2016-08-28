//
//  AppDelegate.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData
import MapKit

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
    
//    func loadMap(frame: CGRect) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.mapType = .Hybrid
//        NSUserDefaults.standardUserDefaults().setObject(mapView, forKey: "MapView")
//        return mapView
//    }
    
    func loadHistoryMap() {
        let entity = NSEntityDescription.entityForName("Map", inManagedObjectContext: coreDataStack.context)
        let map1 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map1.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-338bc")!)
        map1.name = "The beginning: Conquest of the Latin League."
        map1.area = "Rome"
        map1.era = "BC"
        map1.year = -338
        map1.neLatitude = 47.6683072436119
        map1.neLongtitude = 22.852896988186
        map1.swLatitude = 36.1479296778893
        map1.swLongtitude = 3.4172398379824
        
        let map2 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map2.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-279bc")!)
        map2.name = "Minimum: Losses to Pyrrhus."
        map2.area = "Rome"
        map2.era = "BC"
        map2.year = -86
        map2.neLatitude = 47.6683072436119
        map2.neLongtitude = 22.852896988186
        map2.swLatitude = 36.1479296778893
        map2.swLongtitude = 3.4172398379824

        let map3 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map3.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-212bc")!)
        map3.name = "Minimum: Hannibal's Campaigns"
        map3.area = "Rome"
        map3.era = "BC"
        map3.year = -212
        map3.neLatitude = 47.6683072436119
        map3.neLongtitude = 22.852896988186
        map3.swLatitude = 36.1479296778893
        map3.swLongtitude = 3.4172398379824
        
        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
        map4.name = "Minimum: Losses to Mithridates"
        map4.area = "Rome"
        map4.era = "BC"
        map4.year = -86
        map4.neLatitude = 47.6683072436119
        map4.neLongtitude = 22.852896988186
        map4.swLatitude = 36.1479296778893
        map4.swLongtitude = 3.4172398379824
        
        let map5 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map5.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-9ad")!)
        map5.name = "Maximum: Augustus' Conquest of Germany"
        map5.area = "Rome"
        map5.era = "AD"
        map5.year = 9
        map5.neLatitude = 47.6683072436119
        map5.neLongtitude = 22.852896988186
        map5.swLatitude = 36.1479296778893
        map5.swLongtitude = 3.4172398379824
        
        let map6 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map6.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-116ad")!)
        map6.name = "Maximum: Trajan's Victory over the Parthians"
        map6.area = "Rome"
        map6.era = "AD"
        map6.year = 116
        map6.neLatitude = 47.6683072436119
        map6.neLongtitude = 22.852896988186
        map6.swLatitude = 36.1479296778893
        map6.swLongtitude = 3.4172398379824
        
        let map7 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map7.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-269ad")!)
        map7.name = "Minimum: Secession of the Gallic Empire and Palmyra"
        map7.area = "Rome"
        map7.era = "AD"
        map7.year = 269
        map7.neLatitude = 47.6683072436119
        map7.neLongtitude = 22.852896988186
        map7.swLatitude = 36.1479296778893
        map7.swLongtitude = 3.4172398379824
        
        let map8 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        map8.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-336ad")!)
        map8.name = "Maximum: Reunification under Constantine"
        map8.area = "Rome"
        map8.era = "AD"
        map8.year = 336
        map8.neLatitude = 47.6683072436119
        map8.neLongtitude = 22.852896988186
        map8.swLatitude = 36.1479296778893
        map8.swLongtitude = 3.4172398379824
        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824
//        
//        let map4 = Map(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
//        map4.mapImageData = UIImagePNGRepresentation(UIImage(named: "RE-86bc")!)
//        map4.name = "Minimum: Losses to Mithridates"
//        map4.area = "Rome"
//        map4.era = "BC"
//        map4.year = 86
//        map4.neLatitude = 47.6683072436119
//        map4.neLongtitude = 22.852896988186
//        map4.swLatitude = 36.1479296778893
//        map4.swLongtitude = 3.4172398379824

        
        do {
            try coreDataStack.context.save()
        } catch {
            fatalError("Error: \(error)")
        }
    }

}

