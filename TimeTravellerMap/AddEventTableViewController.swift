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

class AddEventTableViewController: UITableViewController {
    var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var latitudeTextField: UITextField!
    
    @IBOutlet weak var longtitudeTextField: UITextField!
    
    @IBOutlet weak var videoLinkURLTextField: UITextField!
    @IBOutlet weak var videoWebView: UIWebView!
    
//    @IBOutlet weak var otherURLsTextView: UITextView!
    var links: NSOrderedSet = NSOrderedSet()
    var event: Event?
    var name: String? = ""
    var date: String? = ""
    var area: String? = ""
    var latitude: String? = ""
    var longtitude: String? = ""
    var coordinate = CLLocationCoordinate2DMake(0, 0)
    var eventDescription: String? = ""
    var videoURL: String? = ""
    var otherURLs: String? = ""
    var eventToEdit: Event? {
        didSet {
            if let event = eventToEdit {
                name = event.name
                date = event.date
                area = event.area
                coordinate = CLLocationCoordinate2DMake(event.latitude, event.longtitude)
                self.event = event
                eventDescription = event.eventDescription
                videoURL = event.videoURL
                otherURLs = event.otherURLs
                if let links = event.links {
                    self.links = links
                }
            }
        }
    }
    
    var eventAddToMap: Bool = false
    
//    var eventToAdd: Event? {
//        didSet {
//            if let event = eventToAdd {
//                coordinate = CLLocationCoordinate2DMake(event.latitude, event.longtitude)
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        //Insert a new Walk entity into Core Data
        
        if let _ = eventToEdit {
            title = "Edit Event"
            nameTextField.text = name
            dateTextField.text = date
            areaTextField.text = area
            latitudeTextField.text = String(format: "%.8f", coordinate.latitude)
            longtitudeTextField.text = String(format: "%.8f", coordinate.longitude)
            descriptionTextView.text = eventDescription
            videoLinkURLTextField.text = videoURL
            playVideo(videoURL!)
//            otherURLsTextView.text = otherURLs
            
        }
        
        if eventAddToMap {
            latitudeTextField.text = String(format: "%.8f", coordinate.latitude)
            longtitudeTextField.text = String(format: "%.8f", coordinate.longitude)
            reverseGeocodeLocation()
        }
        
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        self.view.endEditing(true)
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
        
        if let temp = eventToEdit {
            hudView.text = "updated"
        } else {
            hudView.text = "Saved"
            event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: managedContext) as! Event
        }
        
        event!.name = nameTextField.text
        event!.date = dateTextField.text
        event!.area = areaTextField.text?.uppercaseString
        event!.eventDescription = descriptionTextView.text
        event!.latitude = Double(latitudeTextField.text!)!
        event!.longtitude = Double(longtitudeTextField.text!)!
        event!.videoURL = videoLinkURLTextField.text
//        event!.otherURLs = otherURLsTextView.text
        event!.links = links
        
        do {
            try managedContext.save()
            if let _ = eventToEdit {
                performSegueWithIdentifier("UpdateEvent", sender: self)
            } else if eventAddToMap {
                performSegueWithIdentifier("AddEventAnnotation", sender: self)
            }
        } catch {
            print("error: \(error)")
        }
        
        afterDelay(0.6) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // MARK: - Function
    func afterDelay(seconds: Double, closure: () -> ()) {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue(), closure)
    }
    
//    func addNewEvent() {
//        let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: managedContext) as! Event
//        event.name = nameTextField.text?.uppercaseString
//        event.date = dateTextField.text
//        event.area = areaTextField.text
//        event.eventDescription = descriptionTextView.text
////        event.location = addLocation()
//        
//        do {
//            try managedContext.save()
//        } catch {
//            fatalError("Error: \(error)")
//        }
//    }
    
    func firstLetterUppercase(text: String) -> String {
        return String(text.characters.first!).capitalizedString + String(text.characters.dropFirst())
    }
    
//    func addLocation() -> Location? {
//        let location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedContext) as! Location
//        location.latitude = Double(latitudeTextField.text!)
//        location.longtitude = Double(longtitudeTextField.text!)
//        return location
//    }
    
    func editEvent() {
        
    }
    
    func geocodeAddressToCoordinate() {
        let gecoder = CLGeocoder()
        let addressString = areaTextField.text!
        gecoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error != nil {
                print("location to coordinate error: \(error?.localizedDescription)")
                return
            }
            
            if let placemarks = placemarks where placemarks.count > 0 {
                let pm = placemarks[0]
                self.latitudeTextField.text = String(pm.location!.coordinate.latitude)
                self.longtitudeTextField.text = String(pm.location!.coordinate.longitude)
                print("location \(pm.location?.coordinate)")
            } else {
                print("No place found")
            }
            
        }
    }
    
    func reverseGeocodeLocation() {
        let gecoder = CLGeocoder()
        let location = CLLocation(latitude: Double(latitudeTextField.text!)!, longitude: Double(longtitudeTextField.text!)!)
        gecoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print("reverse location to coordinate error: \(error?.localizedDescription)")
                return
            }
            
            if let placemarks = placemarks where placemarks.count > 0 {
                let pm = placemarks[0]
                var address: String = "Place unclear"
                if let thoroughfare = pm.thoroughfare {
                    address = ""
                    address = address + thoroughfare + " "
                }
                if let locality = pm.locality {
                    address = address + locality + " "
                }
                if let country = pm.country {
                    address = address + country
                }
                self.areaTextField.text = "\(address)"
                print("reverse location \(address)")
            } else {
                print("reverse No place found")
            }

        }
    }
    
    @IBAction func SetLinks(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! LinksTableViewController
        links = controller.links
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 5
        } else if section == 2 {
            return 3
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 2 && indexPath.row == 2 {
            return indexPath
        }
        return nil
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            return 132
        }
        return UITableViewAutomaticDimension
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        if segue.identifier == "UpdateEvent" {
//            
//        }
        if segue.identifier == "ShowUserfulLinks" {
            let controller = segue.destinationViewController as! LinksTableViewController
            controller.managedContext = managedContext
            controller.links = links
        }
    }

}

extension AddEventTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == areaTextField, let text = areaTextField.text where text != "" {
            geocodeAddressToCoordinate()
            textField.resignFirstResponder()
            descriptionTextView.becomeFirstResponder()
            return false
        } else if textField == latitudeTextField {
            if let text = longtitudeTextField.text {
                if text == "" {
                    longtitudeTextField.becomeFirstResponder()
                } else {
                    reverseGeocodeLocation()
                    descriptionTextView.becomeFirstResponder()
                }
            }
            textField.resignFirstResponder()
            return false
        } else if textField == longtitudeTextField {
            if let text = latitudeTextField.text {
                if text == "" {
                    latitudeTextField.becomeFirstResponder()
                } else {
                    reverseGeocodeLocation()
                    descriptionTextView.becomeFirstResponder()
                }
            }
            textField.resignFirstResponder()
            return false
        } else if textField == videoLinkURLTextField {
            playVideo(textField.text!)
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == areaTextField, let text = areaTextField.text where text != "" {
            geocodeAddressToCoordinate()
            textField.resignFirstResponder()
            descriptionTextView.becomeFirstResponder()
        } else if textField == latitudeTextField {
            if let text = longtitudeTextField.text {
                if text == "" {
                    longtitudeTextField.becomeFirstResponder()
                } else {
                    reverseGeocodeLocation()
                    descriptionTextView.becomeFirstResponder()
                }
            }
            textField.resignFirstResponder()
        } else if textField == longtitudeTextField {
            if let text = latitudeTextField.text {
                if text == "" {
                    latitudeTextField.becomeFirstResponder()
                } else {
                    reverseGeocodeLocation()
                    descriptionTextView.becomeFirstResponder()
                }
            }
            textField.resignFirstResponder()
        } else if textField == videoLinkURLTextField {
            playVideo(textField.text!)
            textField.resignFirstResponder()
        }
    }
}

extension AddEventTableViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    func playVideo(url: String) {
        let videoURL = "https://www.youtube.com/embed/Rg6GLVUnnpM"
        videoWebView.allowsInlineMediaPlayback = true
        let videoString = "<iframe width=\(videoWebView.frame.width) height=\(videoWebView.frame.height) src=\(url)?&playsinline=1 frameborder=0 allowfullscreen></iframe>"
        videoWebView.loadHTMLString(videoString, baseURL: nil)
    }
}
