//
//  MapsTableTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 21/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData

class MapsTableViewController: UITableViewController {
    
    var managedContext: NSManagedObjectContext!
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Map", inManagedObjectContext: self.managedContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "area", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "era", ascending: true)
        let sortDescriptor3 = NSSortDescriptor(key: "year", ascending: false)
        let sortDescriptor4 = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2, sortDescriptor3, sortDescriptor4]

        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: "area",
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .Minimal
        searchBar.delegate = self
        searchBar.placeholder = "search map"
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        tableView.tableHeaderView = searchBar
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
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
    
    // Functions
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
    func filterMapForSearch(searchText: String, scope: String = "All") {
        NSFetchedResultsController.deleteCacheWithName("Maps")
        if searchText.isEmpty {
            fetchedResultsController.fetchRequest.predicate = nil
        } else {
//            NSFetchedResultsController.deleteCacheWithName("Maps")
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@ OR year contains[cd] %@", searchText, searchText)
        }
        
        performFetch()
        tableView.reloadData()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
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
    
//    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        
//        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14, width: 300, height: 14)
//        let label = UILabel(frame: labelRect)
//        label.textAlignment = .Center
//        label.font = UIFont.boldSystemFontOfSize(15)
//        
//        label.text = "end"
//        
//        label.textColor = UIColor(white: 1.0, alpha: 0.4)
//        label.backgroundColor = UIColor.clearColor()
//        
//        let seperatorRect = CGRect(x: 15,
//                                   y: tableView.sectionFooterHeight - 0.5,
//                                   width: tableView.bounds.size.width - 15,
//                                   height: 0.5)
//        let seperator = UIView(frame: seperatorRect)
//        seperator.backgroundColor = tableView.separatorColor
//        
//        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionFooterHeight)
//        let view = UIView(frame: viewRect)
//        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
//        view.addSubview(label)
//        view.addSubview(seperator)
//        return view
//
//    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name.uppercaseString
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MapCell", forIndexPath: indexPath) as! MapViewCell

        let map = fetchedResultsController.objectAtIndexPath(indexPath) as! Map
        cell.configureMapForCell(map)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    func showDeleteAlert(map: Map) {
        let controller = UIAlertController(title: "Delete An Old Map ", message: "Are you sure you want to delete this old map permanently", preferredStyle: .ActionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Destructive, handler: { _ in
            self.confirmDelete(map)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            self.cancelDelete()
        })
        
        controller.addAction(confirmAction)
        controller.addAction(cancelAction)
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func confirmDelete(map: Map) {
        managedContext.deleteObject(map)
        
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
            // Delete the row from the data source
            let map = fetchedResultsController.objectAtIndexPath(indexPath) as! Map
            showDeleteAlert(map)
//            managedContext.deleteObject(map)
//            
//            do {
//                try managedContext.save()
//            } catch {
//                fatalError("Error: \(error)")
//            }
        }
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
        if segue.identifier == "AddMap" {
            let nvController = segue.destinationViewController as! UINavigationController
            let controller = nvController.topViewController as! AddMapViewController
            controller.managedContext = managedContext
        } else if segue.identifier == "ShowMapDetails" {
            let controller = segue.destinationViewController as! MapDetailsViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let map = fetchedResultsController.objectAtIndexPath(indexPath) as! Map
                controller.managedContext = managedContext
                controller.map = map
            }
        }
    }

}

extension MapsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterMapForSearch(searchController.searchBar.text!)
    }
}

extension MapsTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension MapsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("MapTableViewController changed")
        tableView.beginUpdates()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "OverlayIsUpdated")
        switch type {
        case .Insert:
            print("MapTableViewController insert")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            print("MapTableViewController delete")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? MapViewCell {
                let map = controller.objectAtIndexPath(indexPath!) as! Map
                cell.configureMapForCell(map)
            }
            print("MapTableViewController update")
        case .Move:
            print("MapTableViewController move")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        switch type {
        case .Insert:
            print("MapTableViewController section insert")
            tableView.insertSections(indexSet, withRowAnimation: .Fade)
        case .Delete:
            print("MapTableViewController section delete")
            tableView.deleteSections(indexSet, withRowAnimation: .Fade)
        case .Update:
            print("MapTableViewController section update")
        case .Move:
            print("MapTableViewController section move")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("MapTableViewController changed finished")
        tableView.endUpdates()
    }
}

