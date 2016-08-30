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
        if NSUserDefaults.standardUserDefaults().boolForKey("hasLaunchedBefore") {
            print("222222222 is not first laucn")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLaunchedBefore")
            NSUserDefaults.standardUserDefaults().synchronize()
//            loadHistoryMap()
//            loadAnnotations()
            print("222222222 is first laucn")
        }
//        loadHistoryMap()
//        loadAnnotations()
        
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
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "OverlayIsUpdated")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "AnnotationIsUpdated")
        
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
        map2.year = -279
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
    
    func loadAnnotations() {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: coreDataStack.context)
        
        let event1 = Event(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        let entityLink = NSEntityDescription.entityForName("Link", inManagedObjectContext: coreDataStack.context)
        let links1 = Link(entity: entityLink!, insertIntoManagedObjectContext: coreDataStack.context)
        links1.address = "http://www.ict.griffith.edu.au/wiseman/Roman/19MapsB.html"
        let links2 = Link(entity: entityLink!, insertIntoManagedObjectContext: coreDataStack.context)
        links2.address = "http://www.roman-empire.net"
        var linksArray = [Link]()
        linksArray.append(links1)
        linksArray.append(links2)
        var links = NSOrderedSet(array: linksArray)
        links1.event = event1
        links2.event = event1
        event1.name = "Conquest of the Latin League"
        event1.latitude = 41.8905568
        event1.longtitude = 12.4942679
        event1.area = "ROME"
        event1.date = "BC338"
        event1.eventDescription = "In 510 BC, the city of Rome overthrew its Etruscan rulers (to the North-West) and became a republic. It rapidly grew in size and power, becoming the leading city in central Italy and supreme commander of the League of Latin Cities in times of war. In 340 BC the Latin cities revolted, but Rome defeated them and they came under direct Roman rule in 338 BC. This area, the nascent Roman Empire, is indicated in red in the above map. The stippled red area is Capua, an independent area owing allegiance to the Roman Empire. These conventions apply to all of the maps below also. "
        event1.videoURL = "https://www.youtube.com/embed/WG_lHq5GHtM"
        event1.links = links
        
        
        let event2 = Event(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        
        let links3 = Link(entity: entityLink!, insertIntoManagedObjectContext: coreDataStack.context)
        links3.address = "http://www.roman-empire.net"
        linksArray = [Link]()
        linksArray.append(links3)
        
        links = NSOrderedSet(array: linksArray)
        links3.event = event2
        event2.links = links
        
        event2.name = "Losses to Pyrrhus"
        event2.latitude = 40.74301808
        event2.longtitude = 16.76599693
        event2.area = "SANTERAMO IN COLLE,ITALY"
        event2.date = "BC279"
        event2.eventDescription = "In 326-290 BC Rome won the struggle for control of Italy against its main rival, the Samnites to the south-east. "
        event2.videoURL = "https://www.youtube.com/embed/O0MGGgSoAdE"
        
        let event3 = Event(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        
        let links4 = Link(entity: entityLink!, insertIntoManagedObjectContext: coreDataStack.context)
        links4.address = "http://www.roman-empire.net"
        linksArray = [Link]()
        linksArray.append(links4)
        
        links = NSOrderedSet(array: linksArray)
        links4.event = event3
        event3.links = links
        
        
        event3.name = "Hannibal's Campaigns"
        event3.latitude = 39.93416747
        event3.longtitude = 9.22210333
        event3.area = "ARITZO,ITALY"
        event3.date = "BC212"
        event3.eventDescription = "The Romans finally got the better of Pyrrhus in 275 BC, and by 272 BC had secured the entirety of southern Italy."
        event3.videoURL = "https://www.youtube.com/embed/LqElPOyb-S4"
        
        let event4 = Event(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        
        let links5 = Link(entity: entityLink!, insertIntoManagedObjectContext: coreDataStack.context)
        links5.address = "http://www.roman-empire.net"
        linksArray = [Link]()
        linksArray.append(links5)
        
        links = NSOrderedSet(array: linksArray)
        links5.event = event4
        event4.links = links
        
        event4.name = "Conquest of Germany"
        event4.latitude = 50.6275416
        event4.longtitude = 9.9584503
        event4.area = "GERMANY"
        event4.date = "AD9"
        event4.eventDescription = "Rome's efforts to put Mithradates back in his place were hampered by civil strife at home between the populists lead by Marius and the aristocrats lead by Sulla."
        event4.videoURL = "https://www.youtube.com/embed/IYYAd4WGFWw"
        
        let event5 = Event(entity: entity!, insertIntoManagedObjectContext: coreDataStack.context)
        event5.name = "Trajan's Victory"
        event5.latitude = 53.7660138385598
        event5.longtitude = -0.266101304019816
        event5.area = "PARTHIANS"
        event5.date = "AD116"
        event5.eventDescription = "Rome's rival to the east. He annexed Armenia in 114, northern Mesopotamia in 115, and occupied southern Mesopotamia all the way to the Persian gulf in 116."
        event5.videoURL = "https://www.youtube.com/embed/KRiCVO18LOk"
        
        let links6 = Link(entity: entityLink!, insertIntoManagedObjectContext: coreDataStack.context)
        links6.address = "http://www.roman-empire.net"
        linksArray = [Link]()
        linksArray.append(links6)
        
        links = NSOrderedSet(array: linksArray)
        links6.event = event5
        event5.links = links
        
        do {
            try coreDataStack.context.save()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
}

