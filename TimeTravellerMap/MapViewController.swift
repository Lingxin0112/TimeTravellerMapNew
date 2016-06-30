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
    
    @IBOutlet weak var alphaSlider: UISlider!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var chooseDateTextField: UITextField!
    @IBOutlet weak var endDateLabel: UILabel!
    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    let historyMap = HistoryMap()
    var overlayView: HistoryMapOverlayView?

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
        
        // 
        let latDelta = historyMap.southWestCoordinate.latitude -
            historyMap.northEastCoordinate.latitude
        
        // think of a span as a tv size, measure from one corner to another
//        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        let span = MKCoordinateSpanMake(0.2, 0.0)
        let region = MKCoordinateRegionMake(historyMap.midCoordinate, span)
        
        mapView.region = region
        addOverlay()
        print(overlayView?.overlayImage.size)
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
        let year = String(Int(self.dateSlider.value))
        self.chooseDateTextField.text = year
        updateMap(year)
    }
    
    @IBAction func alphaSliderChanged(sender: UISlider) {
        let alpha = String(format: "%.1f", alphaSlider.value)
        chooseDateTextField.text = alpha
        overlayView?.alpha = CGFloat(Float(alpha)!)
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
//        updateSlider()
        self.view.endEditing(true)
    }
    
    @IBAction func hideOverlay(sender: UIButton) {
        let secondImageView = UIImageView(image: UIImage(named: "Newark1916"))
        secondImageView.alpha = 0.0
        secondImageView.frame = view.frame
        view.addSubview(secondImageView)
        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
            secondImageView.alpha = 1.0
            }, completion: { _ in
        })
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
            secondImageView.alpha = 0.0
            self.overlayView?.setNeedsDisplay()
            self.overlayView?.overlayImage = secondImageView.image!
            }, completion: { _ in
                secondImageView.removeFromSuperview()
        })
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
    
    func addOverlay() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        let overlay = HistoryMapOverlay(historyMap: historyMap)
        mapView.addOverlay(overlay)
    }
    
    func updateMap(year: String) {
        if let newImage = UIImage(named: "Newark\(year)") {
            let newImageView = UIImageView(image: newImage)
            newImageView.alpha = 0.0
            newImageView.frame = view.frame
            view.addSubview(newImageView)
            UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
                newImageView.alpha = 1.0
                }, completion: { _ in
            })
            
            UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
                newImageView.alpha = 0.0
                self.overlayView?.setNeedsDisplay()
                self.overlayView?.overlayImage = newImageView.image!
                }, completion: { _ in
                    newImageView.removeFromSuperview()
            })

        }
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
//            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error: '\(error)'")
    }
}

// MARK: - UITextFieldDelegate

extension MapViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Go {
            updateSlider()
            self.chooseDateTextField.resignFirstResponder()
            return true
        }
        
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateMap(textField.text!)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is HistoryMapOverlay {
            let historyMapImage = UIImage(named: "Newark1800.jpg")
            let overlayView = HistoryMapOverlayView(overlay: overlay, overlayImage: historyMapImage!)
//            overlayView.alpha = 1.0
            self.overlayView = overlayView
            return overlayView
        } 
        
        return MKOverlayRenderer()
    }
}
