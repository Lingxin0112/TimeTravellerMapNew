//
//  FirstViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    var managedContext: NSManagedObjectContext!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dateSlider: UISlider!
    @IBOutlet weak var minYearLabel: UILabel!
    
    @IBOutlet weak var maxYearLabel: UILabel!
    @IBOutlet weak var alphaSlider: UISlider!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var chooseDateTextField: UITextField!
    @IBOutlet weak var endDateLabel: UILabel!

    @IBOutlet weak var containerView: UIView!
    

    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
//    var historyMap = HistoryMap()
    var overlayView: HistoryMapOverlayView?
    var historyMapImage: UIImage?

    var data: [String] = []
    var alpha = ["0.0", "0.1","0.2","0.3","0.4", "0.5", "0.6",  "0.7", "0.8", "0.9", "1.0"]
    var picker = UIPickerView()
    
    let oldImageView = UIImageView()
    let newImageView = UIImageView()
    
    var oldYear = 1500
    var newYear = -330
    
    var state: String = "first"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let searchLocationsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("SearchLocationsTableViewController") as! SearchLocationsTableViewController
        searchLocationsTableViewController.mapView = mapView
        searchLocationsTableViewController.mark = "Main"
        resultSearchController = UISearchController(searchResultsController: searchLocationsTableViewController)
        resultSearchController?.searchResultsUpdater = searchLocationsTableViewController
        
        let searchBar = resultSearchController!.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Places"
        navigationItem.titleView = searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation =  false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        
        
        // 
//        let latDelta = historyMap.southWestCoordinate.latitude -
//            historyMap.northEastCoordinate.latitude
        
        // think of a span as a tv size, measure from one corner to another
//        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
//        let span = MKCoordinateSpanMake(0.2, 0.0)
//        let region = MKCoordinateRegionMake(historyMap.midCoordinate, span)
//        
//        mapView.region = region
        let initialLocation = CLLocation(latitude: 53.3811, longitude: -1.4701)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, 1000 * 2.0, 1000 * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsCompass = true
        mapView.showsScale = true
        
//        addOverlay()
        
        // picker
        picker.delegate = self
        picker.dataSource = self
        chooseDateTextField.inputView = picker
        picker.selectRow(2, inComponent: 0, animated: true)
        picker.selectRow(2, inComponent: 1, animated: true)

        let toolBar = UIToolbar()
        toolBar.barStyle = .Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor.blackColor()
        toolBar.sizeToFit()
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil))
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(MapViewController.donePicker))
        items.append(doneButton)
        toolBar.setItems(items, animated: false)
        toolBar.userInteractionEnabled = true
        chooseDateTextField.inputAccessoryView = toolBar
        
        loadMaps()
    }
    
    
    var maps: [Map]!
    
    func loadMaps() {
        let fetchRequest = NSFetchRequest()
        let mapEntity = NSEntityDescription.entityForName("Map", inManagedObjectContext: managedContext)
        fetchRequest.entity = mapEntity
        do {
            maps = try managedContext.executeFetchRequest(fetchRequest) as! [Map]
            print("maps count: \(maps.count)")
        } catch {
            fatalError("Error: \(error)")
        }
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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let isLaunch = NSUserDefaults.standardUserDefaults().boolForKey("Launch")
        if !isLaunch {

            let launchView = LaunchView.launchView(view, animated: true)
            let window = UIApplication.sharedApplication().keyWindow
                        window?.addSubview(launchView)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "Launch")
        }
        
//        mapView.removeAnnotations(mapView.annotations)
        state = "refresh"
        if NSUserDefaults.standardUserDefaults().boolForKey("OverlayUpdated") {
            chooseMapInTheArea()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "OverlayUpdated")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func dateSliderChanged(sender: UISlider) {
        let year = String(Int(self.dateSlider.value))
        var ascending: Bool = false
        if Int(year)! > currentYear {
            ascending = true
        } else {
            ascending = false
        }
//        dateAndAlphaDict["date"] = year
//        self.chooseDateTextField.text = "\(dateAndAlphaDict["date"]!) + \(dateAndAlphaDict["alpha"]!)"
        
        currentYear = Int(year)!
        
        
//        newYear = Int(self.dateSlider.value)
        updateMap(year, ascending: ascending)
    }
    
    @IBAction func alphaSliderChanged(sender: UISlider) {
        let alpha = String(format: "%.1f", alphaSlider.value)

        overlayView?.alpha = CGFloat(Float(alpha)!)
    }

    var alphaValue: Float = 1.0 {
        didSet {
            overlayView?.alpha = CGFloat(alphaValue)
        }
    }
    
    var ascending = false
    var currentYear: Int = 0 {
        willSet(newValue) {
            if newValue > currentYear {
                ascending = true
            } else {
                ascending = false
            }
        }
        didSet {
            var eraCurrentYear: String = "AD" + "\(currentYear)"
            var eraMapYear: String = "AD" + "\(mapYear)"
            if currentYear < 0 {
                eraCurrentYear = "BC" + "\(-currentYear)"
            }
            if mapYear < 0 {
                eraMapYear = "BC" + "\(-mapYear)"
            }
            self.chooseDateTextField.text = eraCurrentYear + "(" + eraMapYear + ")"
        }
    }
    
    var mapYear: Int = 0 {
        didSet {
            var eraCurrentYear: String = "AD" + "\(currentYear)"
            var eraMapYear: String = "AD" + "\(mapYear)"
            if currentYear < 0 {
                eraCurrentYear = "BC" + "\(-currentYear)"
            }
            if mapYear < 0 {
                eraMapYear = "BC" + "\(-mapYear)"
            }
            self.chooseDateTextField.text = eraCurrentYear + "(" + eraMapYear + ")"
        }
    }
    
    func configureRangeOfDateSlider(maps: [Map]) {
        if maps.count == 0 {
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Year], fromDate: date)
            let year = components.year
            minYearLabel.text = String(year)
            maxYearLabel.text = String(year)
            dateSlider.minimumValue = Float(year)
            dateSlider.maximumValue = Float(year)
            data = []
            data.append(String(year))
        } else if maps.count == 1 {
            let year = maps[0].year! as Int
            minYearLabel.text = String(year - 100)
            maxYearLabel.text = String(year + 100)
            dateSlider.minimumValue = Float(year - 100)
            dateSlider.maximumValue = Float(year + 100)
            data = []
            data.append(String(year - 100))
            data.append(String(year + 100))
            if let old = oldMap where old == maps[0] {
                return
            }
            oldMap = maps[0]
            addMapOverlay(oldMap!)
            dateSlider.value = dateSlider.maximumValue
            
            currentYear = Int(self.dateSlider.maximumValue)
            mapYear = Int(self.dateSlider.maximumValue)
        } else if maps.count > 1 {
            let minMap = maps[0]
            let maxMap = maps[maps.count - 1]
            let minYear = minMap.year! as Int
            let maxYear = maxMap.year! as Int
            minYearLabel.text = String(minYear - 100)
            maxYearLabel.text = String(maxYear + 100)
            dateSlider.minimumValue = Float(minYear - 100)
            dateSlider.maximumValue = Float(maxYear + 100)
            data = []
            for i in (minYear - 100)...(maxYear + 100) {
                data.append("\(i)")
            }
            if let old = oldMap where maps.contains(old) {
                dateSlider.value = Float(old.year!)
                
                currentYear = Int(old.year!)
                mapYear = Int(old.year!)
                return
            }
            oldMap = maxMap
            addMapOverlay(oldMap!)
            dateSlider.value = dateSlider.maximumValue
            
            currentYear = Int(self.dateSlider.maximumValue)
            mapYear = Int(self.dateSlider.maximumValue)
        }
        
        

    }
    
    var left: CGPoint?
    var right: CGPoint?
    
    @IBAction func getCoordinate(sender: UITapGestureRecognizer) {
        
        let point = sender.locationInView(mapView)
        let tapPoint = mapView.convertPoint(point, toCoordinateFromView: containerView)
        let a = containerView.convertPoint(point, fromCoordinateSpace: mapView)
        print("aaaa \(a)")
        let southWestCoordinate = CLLocationCoordinate2D(latitude: 40.712216, longitude: -74.22655)
        let northEastCoordinate = CLLocationCoordinate2D(latitude: 40.773941, longitude: -74.12544)
        left = mapView.convertCoordinate(southWestCoordinate, toPointToView: containerView)
        right = mapView.convertCoordinate(northEastCoordinate, toPointToView: containerView)
        print("left:\(left), right:\(right)")
        let b = containerView.convertPoint(overlayView!.overlayRect.origin, fromCoordinateSpace: mapView)
        print("bbbb\(b)")
//        let c = containerView.convertPoint(overlayView!.overlayRect.size, fromCoordinateSpace: mapView)
//        print("bbbb\(b)")
        print("tap coordinate: \(tapPoint.latitude), \(tapPoint.longitude)")
    }
    
    @IBAction func addAnnotation(sender: UILongPressGestureRecognizer) {
        
        guard sender.state == .Began else {
            return
        }
        
        let point = sender.locationInView(mapView)
        let tapPoint = mapView.convertPoint(point, toCoordinateFromView: containerView)
        
        let annotationStoryboard = UIStoryboard(name: "Annotation", bundle: nil)
        let navigationControoler = annotationStoryboard.instantiateViewControllerWithIdentifier("AddEventNavigationController") as! UINavigationController
        let controller = navigationControoler.topViewController as! AddEventTableViewController
        controller.managedContext = managedContext
        
        controller.coordinate = tapPoint
        controller.eventAddToMap = true
        presentViewController(navigationControoler, animated: true, completion: nil)
        
    }
    
    @IBAction func addEventAnnotation(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! AddEventTableViewController
        let event = controller.event
        let annotation = InformationAnnotation(coordinate: event!.coordinate, title: event!.name!, subtitle: event!.area!, url: nil)
        self.mapView.addAnnotation(annotation)
    }
    
    func showLocationServicesDeniedAlert() {
        let alertController = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // FIXME: change
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
        if segue.identifier == "ChooseLocation" {
            let controller = segue.sourceViewController as! SearchLocationsTableViewController
            let chooseLocation = controller.selectedItem
            state = "search"
            dropPinZoomIn(chooseLocation.placemark)
            
            print(chooseLocation.name)
        }
    }
    
    var draw: Bool = true
    
    var mapType: String?
    @IBAction func chooseMapType(segue: UIStoryboardSegue) {
        if segue.identifier == "ChooseMapType" {
            let controller = segue.sourceViewController as! ToolsTableViewController
            mapType = controller.mapType
            if mapType == "standard" {
                mapView.mapType = .Standard
            } else if mapType == "hybrid" {
                mapView.mapType = .Hybrid
            } else {
                mapView.mapType = .Satellite
            }
        }
    }
    
    
    func transform(oldMap: Map, newMap: Map, ascending: Bool) {

        let oldRect = mapView.convertRegion(oldMap.getMapRegion(), toRectToView: containerView)
        let newRect = mapView.convertRegion(newMap.getMapRegion(), toRectToView: containerView)
        
        let oldMapImageView = UIImageView(frame: oldRect)
        let newMapImageView = UIImageView(frame: newRect)
        oldMapImageView.image = UIImage(data: oldMap.mapImageData!)
        newMapImageView.image = UIImage(data: newMap.mapImageData!)
        oldMapImageView.alpha = CGFloat(alphaSlider.value)
        newMapImageView.alpha = CGFloat(alphaSlider.value)
        
        containerView.addSubview(oldMapImageView)
        containerView.addSubview(newMapImageView)
        
        addMapOverlay(newMap)
        historyMapImage = newMapImageView.image
        overlayView?.alpha = 0.0
        
        if ascending {
            newMapImageView.center.x -= 300
            UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                oldMapImageView.center.x += 300
                newMapImageView.center.x += 300
//                self.overlayView?.overlayImage = newMapImageView.image!
                }, completion: { _ in
//                    newMapImageView.removeFromSuperview()
//                    oldMapImageView.removeFromSuperview()
                    self.afterDelay(1) {
                        newMapImageView.removeFromSuperview()
                        oldMapImageView.removeFromSuperview()
                    }
                    
                    self.overlayView?.alpha = CGFloat(self.alphaSlider.value)
            })
        } else {
            newMapImageView.center.x += 300
            UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                oldMapImageView.center.x -= 300
                newMapImageView.center.x -= 300
//                self.overlayView?.overlayImage = newMapImageView.image!
                }, completion: { _ in
//                    newMapImageView.removeFromSuperview()
//                    oldMapImageView.removeFromSuperview()
                    self.afterDelay(1) {
                        newMapImageView.removeFromSuperview()
                        oldMapImageView.removeFromSuperview()
                    }
                    
                    self.overlayView?.alpha = CGFloat(self.alphaSlider.value)
            })
        }
        
        self.oldMap = self.newMap
        
    }
    
    // MARK: - Delay
    func afterDelay(seconds: Double, closure: () -> ()) {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue(), closure)
    }
    
    @IBAction func popover(sender: UIBarButtonItem) {
        performSegueWithIdentifier("ShowTools", sender: self)
    }
    
    func addMapOverlay(map: Map) {
//        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
//        historyMap = HistoryMap(map: map)
        let overlay = HistoryMapOverlay(historyMap: map)
        historyMapImage = UIImage(data: map.mapImageData!)
        mapView.addOverlay(overlay)
    }
    
    func addInformationPins() {
//        var coordinate = CLLocationCoordinate2DMake(40.72422, -74.22544)
//        var title = "Newark"
//        var subtitle = "This is a test"
//        var annotation = InformationAnnotation(coordinate: coordinate, title: title, subtitle: subtitle)
//        mapView.addAnnotation(annotation)
//        
//        coordinate = CLLocationCoordinate2DMake(40.712216, -74.22655)
//        title = "Newark1"
//        subtitle = "This is a test1"
//        annotation = InformationAnnotation(coordinate: coordinate, title: title, subtitle: subtitle)
//        mapView.addAnnotation(annotation)
//        
//        coordinate = CLLocationCoordinate2DMake(40.773941, -74.12544)
//        title = "Newark2"
//        subtitle = "This is a test2"
//        annotation = InformationAnnotation(coordinate: coordinate, title: title, subtitle: subtitle)
//        mapView.addAnnotation(annotation)
        
        let fetchRequest = NSFetchRequest(entityName: "Event")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [Event]
            for event in results {
                if event.isInThisArea(mapView.visibleMapRect)
                {
                    let annotation = InformationAnnotation(event: event)
                    mapView.addAnnotation(annotation)
                }
            }
            
        } catch let error as NSError {
            fatalError("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    var oldMap: Map?
    var newMap: Map?
    
    func updateMap(year: String, ascending: Bool) {
        newImageView.stopAnimating()
        newYear = Int(year)!
        let fetchRequest = NSFetchRequest(entityName: "Map")
        var predict: NSPredicate
        if newYear < oldYear {
            predict = NSPredicate(format: "comment = %@ and year >= %d and year <= %d", "Yes", newYear, oldYear)
        } else {
            predict = NSPredicate(format: "comment = %@ and year >= %d and year <= %d", "Yes", oldYear, newYear)
        }
        
        fetchRequest.predicate = predict
        let sortDescriptor = NSSortDescriptor(key: "year", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let maps = try managedContext.executeFetchRequest(fetchRequest) as! [Map]
            if maps.count == 1 {
                newMap = maps[0]
                if newMap != oldMap {
                    transform(oldMap!, newMap: newMap!, ascending: ascending)
                    mapYear = newMap!.year as! Int
                }
                
            } else if maps.count > 1 {
                var imageArray : [UIImage] = []
                for map in maps {
                    let image = UIImage(data: map.mapImageData!)
                    imageArray.append(image!)
                }

                if ascending {
                    addMapOverlay(maps[maps.count - 1])
                    mapYear = maps[maps.count - 1].year as! Int
                    
                } else {
                    addMapOverlay(maps[0])
                    mapYear = maps[0].year as! Int
                }
                
                overlayView?.alpha = 0.0
                performSegueWithIdentifier("MapsAnimation", sender: imageArray)
            }
            oldYear = newYear
        } catch {
            fatalError("Error: \(error)")
        }
        
    }
    
    func donePicker() {
        chooseDateTextField.resignFirstResponder()
        updateMap(String(currentYear), ascending: ascending)
        
    }
    
    func chooseMapInTheArea() {
        
        // get visible area
        let visibleRect = mapView.visibleMapRect
        
        var maps: [Map] = []
        var localMaps: [Map] = []
        let fetchRequest = NSFetchRequest(entityName: "Map")
        let sortDescriptor = NSSortDescriptor(key: "year", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            maps = try managedContext.executeFetchRequest(fetchRequest) as! [Map]
        } catch {
            fatalError("Error: \(error)")
        }
        for map in maps {
            let mapRect = map.mapRect
            
            if MKMapRectIntersectsRect(visibleRect, mapRect) {
                map.comment = "Yes"
                localMaps.append(map)
            } else {
                map.comment = "No"
            }
    
            do {
                try managedContext.save()
            } catch {
                fatalError("Error: \(error)")
            }
        }
        configureRangeOfDateSlider(localMaps)
    }
    
    @IBAction func closeImagesAnimation(segue: UIStoryboardSegue) {
        if let overlayView = overlayView {
            overlayView.alpha = CGFloat(alphaSlider.value)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTools" {
            let vc = segue.destinationViewController as! ToolsTableViewController
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
            
        } else if segue.identifier == "ShowAnnotationDetails" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let vc = navigationController.topViewController as! AnnotationDetailsTableViewController
            let annotation = sender as! InformationAnnotation
            vc.annotation = annotation
        } else if segue.identifier == "AddEvent" {
            
        } else if segue.identifier == "MapsAnimation" {
            let controller = segue.destinationViewController as! MapsAnimationViewController
            let imageArray = sender as! [UIImage]
            controller.imageArray = imageArray
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
//            let span = MKCoordinateSpanMake(0.5 0.5)
//            let region = MKCoordinateRegion(center: location.coordinate, span: span)
//            mapView.setRegion(region, animated: true)
//            let initialLocation = CLLocation(latitude: 53.3811, longitude: -1.4701)
//            let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, 1000 * 2.0, 1000 * 2.0)
//            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error: '\(error)'")
    }
}

// MARK: - UITextFieldDelegate

extension MapViewController: UITextFieldDelegate {
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if textField.returnKeyType == .Go {
//            updateSlider()
//            self.chooseDateTextField.resignFirstResponder()
//            return true
//        }
//        
//        return false
//    }
    
    func textFieldDidEndEditing(textField: UITextField) {
//        updateMap(dateAndAlphaDict["date"]!)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        picker.selectRow(data.indexOf(String(currentYear))!, inComponent: 0, animated: true)
        let currentAlpha = String(format: "%.1f", alphaSlider.value)
        picker.selectRow(alpha.indexOf(currentAlpha)!, inComponent: 1, animated: true)
        
//        print("beigin editing")
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is HistoryMapOverlay {
//            historyMapImage = UIImage(named: "Newark1800.jpg")
            print("overlay \(overlay.boundingMapRect.origin)")
            let overlayView = HistoryMapOverlayView(overlay: overlay, overlayImage: historyMapImage!)
//            overlayView.alpha = 1.0
            self.overlayView = overlayView
            return overlayView
        } 
        
        return MKOverlayRenderer()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // return nil so map view draws "blue dot" for standard user location
        }

        let identifier = "Information"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.pinTintColor = UIColor.orangeColor()
            annotationView?.canShowCallout = true
            annotationView?.tintColor = UIColor(white: 0.0, alpha: 0.5)
            
            let button = UIButton(type: .DetailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView

    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let information = view.annotation as! InformationAnnotation
//        let title = information.title
//        let subtitle = information.subtitle
        
//        let controller = UIAlertController(title: "Information", message: title, preferredStyle: .ActionSheet)
//        let action = UIAlertAction(title: subtitle, style: .Default, handler: nil)
//        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { _ in
//            for subview in view.subviews {
//                subview.removeFromSuperview()
//            }
//        })
//        controller.addAction(action)
//        controller.addAction(okAction)
//        presentViewController(controller, animated: true, completion: nil)
        performSegueWithIdentifier("ShowAnnotationDetails", sender: information)
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if view is MKPinAnnotationView {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        newImageView.hidden = true
        let mapVisibleRect = mapView.visibleMapRect;
//        let eastPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMidY(mapRect));
//        let westPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMidY(mapRect));
//        let currentMapDist = MKMetersBetweenMapPoints(eastPoint, westPoint);
        chooseMapInTheArea()
//        if !MKMapRectIntersectsRect(mapVisibleRect, oldMap!.mapRect) {
//            chooseMapInTheArea()
//        }
//        
//        if state == "first" || state == "search" || state == "refresh" {
//            chooseMapInTheArea()
//            state = "finish"
//        }

        
        addInformationPins()
        
        if let view = overlayView where MKMapRectIntersectsRect(mapVisibleRect, view.overlay.boundingMapRect) {
            print("In this area!!!!!!")
        }
        
//        print("Current map distance is \(currentMapDist)");
    }
}

// MARK: - UIPickerViewDataSource

extension MapViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return data.count
        } else if component == 1 {
            return alpha.count
        } else {
            return 2
        }
    }
    
    
}

// MARK: - UIPickerViewDelegate

extension MapViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            currentYear = Int(data[row])!
            self.dateSlider.value = CFloat(Float(currentYear))
        } else if component == 1 {
//            newDateAndAlphaDict["alpha"] = alpha[row]
            self.alphaSlider.value = CFloat(Float(alpha[row])!)
            alphaValue = Float(alpha[row])!
        }
        
//        if let date = dateAndAlphaDict["date"], let alpha = dateAndAlphaDict["alpha"] {
//            chooseDateTextField.text = "\(date) + \(alpha)"
//        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return data[row]
        } else {
            return alpha[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let pickerWidth = pickerView.bounds.size.width
        if component == 0 {
            return pickerWidth * 2 / 3
        } else {
            return pickerWidth / 3
        }
    }
}

// MARK: - UIPopoverPresentationController

extension MapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}

// MARK: - UIScrollViewDelegate

//    func scrollViewDidZoom(scrollView: UIScrollView) {
//        let boundsSize = self.scrollView.bounds.size
//        let contentFrame = drawMapImageView.frame
//        
////        if contentFrame.size.width < boundsSize.width {
////            contentFrame.origin.x = (boundsSize.width - contentFrame.size.width)/2
////        } else {
////            contentFrame.origin.x = 0.0
////        }
////        
////        if contentFrame.size.height < boundsSize.height {
////            contentFrame.origin.y = (boundsSize.height - contentFrame.size.height)/2
////        } else {
////            contentFrame.origin.y = 0.0
////        }
////        
////        drawMapImageView.frame = contentFrame
//        if contentFrame.height < boundsSize.height {
//            let shiftHeigh = boundsSize.height/2.0 - self.scrollView.contentSize.height/2.0
//            self.scrollView.contentInset.top = shiftHeigh
//        }
//        if contentFrame.width < boundsSize.width {
//            let shiftwidth = boundsSize.width/2.0 - self.scrollView.contentSize.width/2.0
//            self.scrollView.contentInset.left = shiftwidth
//        }
//        
//    }
//}

//// MARK: - BrushSettingsViewControllerDelegate
//
//extension MapViewController: BrushSettingsViewControllerDelegate {
//    func brushSettingsviewControllerFinished(brushSettingsViewController: BrushSettingsViewController) {
//        brushWidth = brushSettingsViewController.brush
//        opacity = brushSettingsViewController.opacity
//    }
//}


// MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
