//
//  ToolsTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 01/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class ToolsTableViewController: UITableViewController {
    
    let tools = ["pencil", "photo", "Zoom"]
    let newTools = ["sahre", "reset"]
    var tool: String?
    
    var brush: CGFloat = 10.0
    var opacity: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        } else {
            return 2
        }
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
        if segue.identifier == "ChooseTool" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) where indexPath.section == 0{
                tool = tools[indexPath.row]
            } else if let indexPath = tableView.indexPathForCell(cell) where indexPath.section == 1 {
                tool = newTools[indexPath.row]
            }
        } else if segue.identifier == "BrushSetting" {
            let vc = segue.destinationViewController as! BrushSettingsViewController
//            vc.delegate = self
            vc.brush = brush
            vc.opacity = opacity
        }

    }

}

//// MARK: - BrushSettingsViewControllerDelegate
//
//extension ToolsTableViewController: BrushSettingsViewControllerDelegate {
//    func brushSettingsviewControllerFinished(brushSettingsViewController: BrushSettingsViewController) {
//        brush = brushSettingsViewController.brush
//        opacity = brushSettingsViewController.opacity
//    }
//}

