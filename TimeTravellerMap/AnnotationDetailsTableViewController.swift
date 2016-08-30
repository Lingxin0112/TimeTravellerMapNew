//
//  AnnotationDetailsTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 12/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class AnnotationDetailsTableViewController: UITableViewController {
    
    var annotation: InformationAnnotation?

    @IBOutlet weak var videoWebView: UIWebView!
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var longtitudeLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var otherURLsTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
        
        latitudeLabel.text = String(annotation!.coordinate.latitude)
        longtitudeLabel.text = String(annotation!.coordinate.longitude)
        if let url = annotation?.videoURL {
            playVideo(url)
        }
        descriptionTextView.text = annotation?.eventDescription
        if let description = annotation?.eventDescription {
            info = description
        }
//        otherURLsTextView.text = annotation!.otherURLs
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Function
    func playVideo(url: String) {
//        let videoURL = "https://www.youtube.com/embed/Rg6GLVUnnpM"
        videoWebView.allowsInlineMediaPlayback = true
        let videoString = "<iframe width=\(videoWebView.frame.width) height=\(videoWebView.frame.height) src=\(url)?&playsinline=1 frameborder=0 allowfullscreen></iframe>"
        videoWebView.loadHTMLString(videoString, baseURL: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 2
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

//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.section == 0 && indexPath.row == 0 {
//            return 132
//        } else if isExpanded && indexPath.section == 1 && indexPath.row == 0 {
//            return 200
//        }
//        return 44
//    }
//    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 132
        }
        return UITableViewAutomaticDimension
    }
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 && indexPath.row == 0 {
            return nil
        }
        return indexPath
    }
    
    let moreInfoText = "Read more"
    var isExpanded = true
    var info = ""
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
        
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
            
            isExpanded = !isExpanded
            
            descriptionTextView.text = isExpanded ? info : moreInfoText
            descriptionTextView.textAlignment = isExpanded ? .Left : .Center
            
            
            UIView.animateWithDuration(0.3) {
                cell.contentView.layoutIfNeeded()
            }
            
            
            tableView.beginUpdates()
            tableView.endUpdates()
            

            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }

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
