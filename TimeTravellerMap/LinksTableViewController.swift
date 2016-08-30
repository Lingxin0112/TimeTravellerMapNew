//
//  LinksTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 17/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData

class LinksTableViewController: UITableViewController {
    
    var managedContext: NSManagedObjectContext!
//
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//        let fetchRequest = NSFetchRequest()
//        let entity = NSEntityDescription.entityForName("Link", inManagedObjectContext: self.managedContext)
//        fetchRequest.entity = entity
//        
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        
//        fetchRequest.fetchBatchSize = 20
//        
//        let fetchedResultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: self.managedContext,
//            sectionNameKeyPath: nil,
//            cacheName: "Links")
//        fetchedResultsController.delegate = self
//        return fetchedResultsController
//    }()

    var barButtonItem: UIBarButtonItem = UIBarButtonItem()
    var links: NSOrderedSet = NSOrderedSet()
    var array = [String]()
    
    var rightItem: String = "" {
        didSet {
            if rightItem == "Add" {
                barButtonItem = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: #selector(LinksTableViewController.addNewLink))
            } else if rightItem == "Done" {
                barButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(LinksTableViewController.saveNewLink))
            }
            self.navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

//        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        rightItem = "Add"
//        self.navigationItem.rightBarButtonItem = barButtonItem
        for _ in links {
            array.append("add")
        }
        
        // appearance
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        performSegueWithIdentifier("SetLinks", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var isNewLink: Bool = false
    
    // MARK: - Action
    func addNewLink() {
        rightItem = "Done"
        array.append("add")
        isNewLink = true
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: array.count - 1, inSection: 0)], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    func saveNewLink() {
        
        let indexPath = NSIndexPath(forRow: array.count - 1, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LinkCell
        
        if cell.linkTextField.text == "" {
            let controller = UIAlertController(title: "Warning", message: "You have not inputed a new adress link", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            controller.addAction(okAction)
            presentViewController(controller, animated: true, completion: nil)
            return
        }
        
        rightItem = "Add"
        //Insert a new Walk entity into Core Data
        let entity = NSEntityDescription.entityForName("Link", inManagedObjectContext: managedContext)
        let link = Link(entity: entity!, insertIntoManagedObjectContext: managedContext)

        
        link.address = cell.linkTextField.text
        let newLinks = links.mutableCopy() as! NSMutableOrderedSet
        newLinks.addObject(link)
        links = newLinks.copy() as! NSOrderedSet
        isNewLink = false
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LinkCell", forIndexPath: indexPath) as! LinkCell

        // Configure the cell...
        if !isNewLink {
            let link = links[indexPath.row] as! Link
            cell.linkTextField.text = link.address
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
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

//extension LinksTableViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        print("EventTableViewController changed")
//        tableView.beginUpdates()
//        
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//        case .Insert:
//            print("EventTableViewController insert")
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        case .Delete:
//            print("EventTableViewController delete")
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//        case .Update:
//            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? EventCell{
//                let event = controller.objectAtIndexPath(indexPath!) as! Event
//                cell.configureCellForEvent(event)
//            }
//            print("EventTableViewController update")
//        case .Move:
//            print("EventTableViewController move")
//            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//        }
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        let indexSet = NSIndexSet(index: sectionIndex)
//        switch type {
//        case .Insert:
//            print("EventTableViewController section insert")
//            tableView.insertSections(indexSet, withRowAnimation: .Fade)
//        case .Delete:
//            print("EventTableViewController section delete")
//            tableView.deleteSections(indexSet, withRowAnimation: .Fade)
//        case .Update:
//            print("EventTableViewController section update")
//        case .Move:
//            print("EventTableViewController section move")
//        }
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        print("EventTableViewController changed finished")
//        tableView.endUpdates()
//    }
//}
