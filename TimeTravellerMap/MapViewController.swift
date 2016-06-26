//
//  FirstViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dateSlider: UISlider!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var chooseDateTextField: UITextField!
    @IBOutlet weak var endDateLabel: UILabel!
    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let searchLocationsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("SearchLocationsTableViewController") as! SearchLocationsTableViewController
        searchLocationsTableViewController.mapView = mapView
        resultSearchController = UISearchController(searchResultsController: searchLocationsTableViewController)
        resultSearchController?.searchResultsUpdater = searchLocationsTableViewController
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Places"
        navigationItem.titleView = searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation =  false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        self.chooseDateTextField.text = String(Int(self.dateSlider.maximumValue))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func dateSliderChanged(sender: UISlider) {
        self.chooseDateTextField.text = String(Int(self.dateSlider.value))
    }
    
    func showLocationServicesDeniedAlert() {
        let alertController = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func searchLocation(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! SearchLocationsTableViewController
        let chooseLocation = controller.selectedItem
        dropPinZoomIn(chooseLocation.placemark)
        print(chooseLocation.name)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateSlider()
        self.view.endEditing(true)
    }
    
    // Functions
    func updateSlider() {
        var inputDate = Float(self.chooseDateTextField.text!)!
        if inputDate < self.dateSlider.minimumValue {
            inputDate = self.dateSlider.minimumValue
        } else if inputDate > self.dateSlider.maximumValue {
            inputDate = self.dateSlider.maximumValue
        }
        self.dateSlider.setValue(inputDate, animated: true)
        self.chooseDateTextField.text = String(Int(inputDate))
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error: '\(error)'")
    }
}

// MARK: - UITextFieldDelegate

extension MapViewController: UITextFieldDelegate {
//    func textFieldDidEndEditing(textField: UITextField) {
//        self.dateSlider.setValue(Float(self.chooseDateTextField.text!)!, animated: true)
//        self.chooseDateTextField.resignFirstResponder()
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Go {
            updateSlider()
            self.chooseDateTextField.resignFirstResponder()
            return true
        }
        
        return false
    }
}

