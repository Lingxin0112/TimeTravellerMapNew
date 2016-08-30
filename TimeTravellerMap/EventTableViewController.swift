//
//  EventTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 13/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData

class EventTableViewController: UITableViewController {

    var managedContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "area", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: "area",
            cacheName: "Events")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
//    lazy var indexedList: Set<String> = {
//        var index: Set<String> = []
//        let sectionInfo = self.fetchedResultsController.sections
//        for section in sectionInfo! {
//            index.insert(section.indexTitle!)
//        }
//        return index
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        performFetch()
        
        
        
        // appearance
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        
        tableView.sectionIndexBackgroundColor = UIColor.blackColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // MARK: - Functions
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error: \(error)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventCell
        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Event
        cell.configureCellForEvent(event)
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14, width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.textAlignment = .Center
        label.font = UIFont.boldSystemFontOfSize(15)
        
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clearColor()
        
        let seperatorRect = CGRect(x: 15,
                                   y: tableView.sectionHeaderHeight - 0.5,
                                   width: tableView.bounds.size.width - 15,
                                   height: 0.5)
        let seperator = UIView(frame: seperatorRect)
        seperator.backgroundColor = tableView.separatorColor
        
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
        view.addSubview(label)
        view.addSubview(seperator)
        return view
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Event
//        performSegueWithIdentifier("ShowEventDetails", sender: event)
//    }
    
    func showDeleteAlert(event: Event) {
        let controller = UIAlertController(title: "Delete An Annotation", message: "Are you sure you want to delete this annotation permanently", preferredStyle: .ActionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Destructive, handler: { _ in
            self.confirmDelete(event)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            self.cancelDelete()
        })
        
        controller.addAction(confirmAction)
        controller.addAction(cancelAction)
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func confirmDelete(event: Event) {
        managedContext.deleteObject(event)
        
        do {
            try managedContext.save()
        } catch {
            fatalError("Error: \(error)")
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelDelete() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Event
            showDeleteAlert(event)
//            managedContext.deleteObject(event)
//            
//            do {
//                try managedContext.save()
//            } catch {
//                fatalError("Error: \(error)")
//            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }

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
        if segue.identifier == "AddEvent" {
            let navController = segue.destinationViewController as! UINavigationController
            let controller = navController.topViewController as! AddEventTableViewController
            controller.managedContext = managedContext
        } else if segue.identifier == "ShowEventDetails" {
            let controller = segue.destinationViewController as! EventDetailsViewController
//            let navController = segue.destinationViewController as! UINavigationController
//            let controller = navController.topViewController as! AddEventTableViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Event
                controller.managedContext = managedContext
                controller.event = event
            }
            
        } 
    }
}

extension EventTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("EventTableViewController changed")
        tableView.beginUpdates()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "AnnotationIsUpdated")
        switch type {
        case .Insert:
            print("EventTableViewController insert")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            print("EventTableViewController delete")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? EventCell{
                let event = controller.objectAtIndexPath(indexPath!) as! Event
                cell.configureCellForEvent(event)
            }
            print("EventTableViewController update")
        case .Move:
            print("EventTableViewController move")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        switch type {
        case .Insert:
            print("EventTableViewController section insert")
            tableView.insertSections(indexSet, withRowAnimation: .Fade)
        case .Delete:
            print("EventTableViewController section delete")
            tableView.deleteSections(indexSet, withRowAnimation: .Fade)
        case .Update:
            print("EventTableViewController section update")
        case .Move:
            print("EventTableViewController section move")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("EventTableViewController changed finished")
        tableView.endUpdates()
    }
}

