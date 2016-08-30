//
//  MapLocationViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 06/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class MapLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    var neLocationCoordinate: CLLocationCoordinate2D?
    var swLocationCoordinate: CLLocationCoordinate2D?
    
    var image: UIImage?
    var coordinateRegion: MKCoordinateRegion?
    var resultSearchController: MySearchController? = nil
    
    // set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 53.3811, longitude: -1.4701)
    var midCoordinate: CLLocationCoordinate2D?
    let regionRadius: CLLocationDistance = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // add search controller
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let searchLocationsTableViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchLocationsTableViewController") as! SearchLocationsTableViewController
        searchLocationsTableViewController.mapView = mapView
        searchLocationsTableViewController.mark = "NotMain"
        resultSearchController = MySearchController(searchResultsController: searchLocationsTableViewController)
        resultSearchController?.searchResultsUpdater = searchLocationsTableViewController
        resultSearchController?.delegate = self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Places"
        searchBar.showsCancelButton = false
        navigationItem.titleView = searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation =  false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        
        if let midCoordinate = midCoordinate {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(midCoordinate, 100000 * 30.0, 100000 * 30.0)
            mapView.setRegion(coordinateRegion, animated: true)
            mapView.showsCompass = true

        } else {
            centerMapOnLocation(initialLocation)
        }
        
        mapImageView.alpha = 0.5
        
        mapImageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    
    @IBAction func alphaSliderChanged(sender: UISlider) {
        mapImageView.alpha = CGFloat(sender.value)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        getTheLocation()
        performSegueWithIdentifier("UpdateMapCoordinate", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion!, animated: true)
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func drawMap(sender: AnyObject) {
//        performSegueWithIdentifier("MapDrawing", sender: nil)
    }
    
    
    func getTheLocation() {
        let swPoint = CGPoint(x: mapImageView.frame.origin.x, y: mapImageView.frame.origin.y + mapImageView.frame.size.height)
        swLocationCoordinate = mapView.convertPoint(swPoint, toCoordinateFromView: view)
        print("newImageview point:\(swLocationCoordinate)")
        
        let nePoint = CGPoint(x: mapImageView.frame.origin.x + mapImageView.frame.size.width, y: mapImageView.frame.origin.y)
        neLocationCoordinate = mapView.convertPoint(nePoint, toCoordinateFromView: view)
        print("newImageview SE_point:\(neLocationCoordinate)")
    }
    
    var left: CGPoint?
    var right: CGPoint?
    
    // TODO: Delete this method
    @IBAction func getCoordinateTapGesture(sender: UITapGestureRecognizer) {
        let point = sender.locationInView(mapView)
        let tapPoint = mapView.convertPoint(point, toCoordinateFromView: view)
        let a = view.convertPoint(point, fromCoordinateSpace: mapView)
//        print("aaaa \(a)")
        let southWestCoordinate = CLLocationCoordinate2D(latitude: 40.712216, longitude: -74.22655)
        let northEastCoordinate = CLLocationCoordinate2D(latitude: 40.773941, longitude: -74.12544)
        left = mapView.convertCoordinate(southWestCoordinate, toPointToView: view)
        right = mapView.convertCoordinate(northEastCoordinate, toPointToView: view)
//        print("left:\(left!), right:\(right!)")

        print("tap coordinate: \(tapPoint.latitude), \(tapPoint.longitude)")
        
        let imagePoint = mapView.convertPoint(mapImageView.bounds.origin, toCoordinateFromView: view)
        print("Point: \(imagePoint)")
    }
    
    func updateMapLocation(placemark: MKPlacemark) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        coordinateRegion = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(coordinateRegion!, animated: true)
    }
    
    // MARK: - Navigation
    
    @IBAction func saveMapDrawing(segue: UIStoryboardSegue) {
        if segue.identifier == "SaveMapDrawing" {
            let controller = segue.sourceViewController as! MapDrawingViewController
            image = controller.image
            mapImageView.image = image
        }
    }
    
    @IBAction func chooseMapLocation(segue: UIStoryboardSegue) {
        if segue.identifier == "ChooseMapLocation" {
            let controller = segue.sourceViewController as! SearchLocationsTableViewController
            let chooseLocation = controller.selectedItem
            updateMapLocation(chooseLocation.placemark)
            print(chooseLocation.name)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UpdateMapCoordinate" {
            let controller = segue.destinationViewController as! AddMapViewController
            controller.neLocationCoordinate = neLocationCoordinate
            controller.swLocationCoordinate = swLocationCoordinate
            controller.image = image
        } else if segue.identifier == "MapDrawing" {
            let controller = segue.destinationViewController as! MapDrawingViewController
            controller.image = image
            controller.coordinateRegion = coordinateRegion
            controller.isExistedMap = false
            if let midCoordinate = midCoordinate {
                controller.midCoordinate = midCoordinate
            }
        }
    }

}

// MARK: - UISearchBarDelegate

extension MapLocationViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

// MARK: - UISearchControllerDelegates

extension MapLocationViewController: UISearchControllerDelegate {
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
}