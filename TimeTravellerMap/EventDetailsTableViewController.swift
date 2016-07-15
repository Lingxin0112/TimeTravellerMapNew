//
//  EventDetailsTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 14/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData
import Dispatch
import CoreLocation

class EventDetailsTableViewController: UITableViewController {
    var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var eventNameTextField: UITextField!

    @IBOutlet weak var eventAreaTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        geocodeAddressToCoordinate()
        reverseGeocodeLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        hudView.text = "Saved"
//        addNewEvent()
        
        afterDelay(0.6) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // MARK: - Function
    func afterDelay(seconds: Double, closure: () -> ()) {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue(), closure)
    }
    func addNewEvent() {
        let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: managedContext) as! Event
        event.name = eventNameTextField.text
        event.area = eventAreaTextField.text
        
        do {
            try managedContext.save()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
    func geocodeAddressToCoordinate() {
        let gecoder = CLGeocoder()
        let addressString = eventAreaTextField.text!
        gecoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error != nil {
                print("location to coordinate error: \(error?.localizedDescription)")
                return
            }
            
            if let placemarks = placemarks where placemarks.count > 0 {
                let pm = placemarks[0] 
                print("location \(pm.location?.coordinate)")
            } else {
                print("No place found")
            }
            
        }
    }
    
    func reverseGeocodeLocation() {
        let gecoder = CLGeocoder()
        let location = CLLocation(latitude: 40.708041999999999, longitude: -87.458100999999999)
        gecoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print("reverse location to coordinate error: \(error?.localizedDescription)")
                return
            }
            
            if let placemarks = placemarks where placemarks.count > 0 {
                let pm = placemarks[0]
                print("reverse location \(pm.locality, pm.country)")
            } else {
                print("reverse No place found")
            }

        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 4
        }
        return 1
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
