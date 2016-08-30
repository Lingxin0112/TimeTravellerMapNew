//
//  SearchLocationsTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class SearchLocationsTableViewController: UITableViewController {
    
    var matchingItems = [MKMapItem]()
    var mapView: MKMapView? = nil
    var selectedItem = MKMapItem()
    var mark: String = "Main"
    var isHasResults: Bool = true
    
    override func viewDidLoad() {
        // appearance
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
    }
    
    deinit {
        print("deinit '\(self)'")
    }
    
    // MARK: - Functions
    
    func parseDetailedAdress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChooseLocation" {
//            let cell = sender as! UITableViewCell
//            if let indexPath = tableView.indexPathForCell(cell) {
//                selectedItem = matchingItems[indexPath.row]
//            }
            let indexPath = sender as! NSIndexPath
            selectedItem = matchingItems[indexPath.row]
        } else if segue.identifier == "ChooseMapLocation" {
            let indexPath = sender as! NSIndexPath
            selectedItem = matchingItems[indexPath.row]
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchLocationsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.isHasResults = false
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else {return}
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler() { response, _ in
            guard let response = response else {return}
            self.isHasResults = true
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
        
    }
}

// MARK: - UITableViewDelegate

extension SearchLocationsTableViewController {
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if !isHasResults {
            return nil
        }
        return indexPath
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        if mark == "Main" {
            performSegueWithIdentifier("ChooseLocation", sender: indexPath)
        } else {
            performSegueWithIdentifier("ChooseMapLocation", sender: indexPath)
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchLocationsTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isHasResults {
            return matchingItems.count
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath)
        if isHasResults {
            let selectedResultItem = matchingItems[indexPath.row].placemark
            cell.textLabel?.text = selectedResultItem.name
            cell.detailTextLabel?.text = parseDetailedAdress(selectedResultItem)
        } else {
            cell.textLabel?.text = "No results"
            cell.detailTextLabel?.text = "Please Try It Later"
        }
        
        cell.backgroundColor = UIColor.blackColor()
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.textLabel!.highlightedTextColor = cell.textLabel!.textColor
        cell.detailTextLabel!.textColor = UIColor(white: 1.0, alpha: 0.6)
        cell.detailTextLabel!.highlightedTextColor = cell.detailTextLabel!.textColor
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
        
        return cell
    }
}