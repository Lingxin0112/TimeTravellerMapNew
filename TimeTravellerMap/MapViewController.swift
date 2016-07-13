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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var drawMapImageView: UIImageView!
//    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    

    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    let historyMap = HistoryMap()
    var overlayView: HistoryMapOverlayView?
    var historyMapImage: UIImage?
    
    lazy var data: [String] = {
        var dataArray = [String]()
        for i in 1800...2016 {
            dataArray.append("\(i)")
        }
        return dataArray
    }()
    var alpha = ["0.0", "0.1","0.2","0.3","0.4", "0.5", "0.6",  "0.7", "0.8", "0.9", "1.0"]
    var picker = UIPickerView()
    var dateAndAlphaDict = [String: String]()
    var newDateAndAlphaDict = [String: String]()
    
    // map drawing
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    var overlayOrDraw: String = "overlay"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scrollView.hidden = true
        scrollView.userInteractionEnabled = false
        drawMapImageView.hidden = true
//        tempImageView.hidden = true
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 6.0
        
        let searchLocationsTableViewController = storyboard!.instantiateViewControllerWithIdentifier("SearchLocationsTableViewController") as! SearchLocationsTableViewController
        searchLocationsTableViewController.mapView = mapView
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
        
        dateAndAlphaDict["date"] = String(Int(self.dateSlider.maximumValue))
        dateAndAlphaDict["alpha"] = String(format: "%.1f", Float(self.alphaSlider.maximumValue))
        self.chooseDateTextField.text = "\(dateAndAlphaDict["date"]!) + \(dateAndAlphaDict["alpha"]!)"
        newDateAndAlphaDict["date"] = dateAndAlphaDict["date"]
        newDateAndAlphaDict["alpha"] = dateAndAlphaDict["alpha"]
        
        // 
        let latDelta = historyMap.southWestCoordinate.latitude -
            historyMap.northEastCoordinate.latitude
        
        // think of a span as a tv size, measure from one corner to another
//        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        let span = MKCoordinateSpanMake(0.2, 0.0)
        let region = MKCoordinateRegionMake(historyMap.midCoordinate, span)
        
        mapView.region = region
        mapView.showsCompass = true
        mapView.showsScale = true
//        mapView.showsTraffic = true
        historyMapImage = UIImage(named: "Newark1800.jpg")
        addOverlay()
        addInformationPins()
        print(overlayView?.overlayImage.size)
        
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
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "donePicker")
        items.append(doneButton)
        toolBar.setItems(items, animated: false)
        toolBar.userInteractionEnabled = true
        chooseDateTextField.inputAccessoryView = toolBar
        
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
        dateAndAlphaDict["date"] = year
        self.chooseDateTextField.text = "\(dateAndAlphaDict["date"]!) + \(dateAndAlphaDict["alpha"]!)"
        updateMap(year)
    }
    
    @IBAction func alphaSliderChanged(sender: UISlider) {
        let alpha = String(format: "%.1f", alphaSlider.value)
        dateAndAlphaDict["alpha"] = alpha
        self.chooseDateTextField.text = "\(dateAndAlphaDict["date"]!) + \(dateAndAlphaDict["alpha"]!)"
        if overlayOrDraw == "overlay" {
            overlayView?.alpha = CGFloat(Float(alpha)!)
        } else {
            drawMapImageView.alpha = CGFloat(Float(alpha)!)
        }
        
    }
    
    let EARTH_RADIUS = 6371
    func convertLatLongToConvert(point: CGPoint) {
//        let x =
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
        print("long press coordinate: \(tapPoint.latitude), \(tapPoint.longitude)")
        
        let coordinate = tapPoint
        var title = "no title"
        var subtitle = "no subtitle"
        let alertController = UIAlertController(title: "Add a annotation pin", message: "Add a pin in press coordinate: \(tapPoint.latitude), \(tapPoint.longitude)", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler() { textField in
            textField.placeholder = "Title"
        }
        alertController.addTextFieldWithConfigurationHandler() { textField in
            textField.placeholder = "Subtitle"
        }
        alertController.addTextFieldWithConfigurationHandler() { textField in
            textField.placeholder = "Video Link"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {
            _ in
            let titleTextFiled = alertController.textFields![0] as UITextField
            title = titleTextFiled.text!
            let subtitleTextFiled = alertController.textFields![1] as UITextField
            subtitle = subtitleTextFiled.text!
            let urlTextFiled = alertController.textFields![2] as UITextField
            let videoURL = urlTextFiled.text!
            
            let annotation = InformationAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, url: videoURL)
            self.mapView.addAnnotation(annotation)
            
        })

        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
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
            dropPinZoomIn(chooseLocation.placemark)
            print(chooseLocation.name)
        }
    }
    
    var draw: Bool = true
    
    @IBAction func chooseTool(segue: UIStoryboardSegue) {
        if segue.identifier == "ChooseTool" {
            let controller = segue.sourceViewController as! ToolsTableViewController
            let tool = controller.tool
            print(tool)
            if tool == "pencil" {
                overlayOrDraw = "draw"
                mapView.removeOverlays(mapView.overlays)

                scrollView.hidden = false
                scrollView.userInteractionEnabled = false
                
                drawMapImageView.hidden = false
//                tempImageView.hidden = false

                mapView.userInteractionEnabled = false
                
//                tempImageView.image = nil
//                drawMapImageView.image = nil
                if draw {
                    drawMapImageView.image = historyMapImage
                    draw = false
                }
                
                brushWidth = controller.brush
                opacity = controller.opacity
            } else if tool == "reset" {
                resetDrawing()
                overlayView?.overlayImage = UIImage(named: "Newark1800.jpg")!
            } else if tool == "zoom" {
                
                mapView.removeOverlays(mapView.overlays)
                scrollView.hidden = false
                drawMapImageView.hidden = false
                scrollView.userInteractionEnabled = true
                mapView.userInteractionEnabled = true
                drawMapImageView.userInteractionEnabled = false
                if draw {
                    drawMapImageView.image = historyMapImage
                    draw = false
                }
            } else if tool == "overlay" {
                overlayOrDraw = "overlay"
                scrollView.hidden = true
                scrollView.userInteractionEnabled = false
                mapView.userInteractionEnabled = true
                addOverlay()
            }
        }
    }
    
    @IBAction func chooseBrush(segue: UIStoryboardSegue) {
        if segue.identifier == "ChooseBrush" {
            let controller = segue.sourceViewController as! BrushSettingsViewController
            brushWidth = controller.brush
            opacity = controller.opacity
            red = controller.red
            green = controller.green
            blue = controller.blue
            print("brushWidth \(controller.brush) + opacity \(controller.opacity)")
        }
    }
    
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(drawMapImageView)
        }
        
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(scrollView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        drawMapImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, opacity)
        CGContextSetBlendMode(context, .Normal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        drawMapImageView.image = UIGraphicsGetImageFromCurrentImageContext()
//        drawMapImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 6
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(drawMapImageView)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }

    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
//        UIGraphicsBeginImageContext(drawMapImageView.frame.size)
//        drawMapImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), blendMode: .Normal, alpha: 1.0)
//        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), blendMode: .Normal, alpha: opacity)
//        drawMapImageView.image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        tempImageView.image = nil
    }
    
    
    @IBAction func hideOverlay(sender: UIButton) {
        let oldImageView = UIImageView(image: UIImage(named: "Newark1800.jpg"))
        let newImageView = UIImageView(image: UIImage(named: "Newark1916"))
        overlayView?.alpha = 0.0
        oldImageView.alpha = 1.0
        newImageView.alpha = 0.0
        
        let overlayRect = overlayView!.overlay.boundingMapRect
        let region = MKCoordinateRegionForMapRect(overlayRect)
        let rect = mapView.convertRegion(region, toRectToView: containerView)
        print("rect \(rect)")
        oldImageView.frame = rect
        newImageView.frame = rect
        newImageView.center.x -= 150
        containerView.addSubview(oldImageView)
        containerView.addSubview(newImageView)
        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseInOut, animations: {
            newImageView.alpha = 1.0
            oldImageView.alpha = 0.0
            oldImageView.center.x += 150
            newImageView.center.x += 150
            self.overlayView?.overlayImage = UIImage(named: "Newark1916")!
            }, completion: { _ in
                self.overlayView?.alpha = 1.0
                newImageView.alpha = 0.0
                newImageView.removeFromSuperview()
                oldImageView.removeFromSuperview()
        })
        
//        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
//            newImageView.alpha = 0.0
//            oldImageView.alpha = 0.0
//            self.overlayView?.alpha = 1.0
//            }, completion: { _ in
//        })
    }
    
    @IBAction func popover(sender: UIBarButtonItem) {
        performSegueWithIdentifier("ShowTools", sender: self)
    }
    // Functions
//    func updateSlider() {
//        var inputDate = Float(self.chooseDateTextField.text!)!
//        if inputDate < self.dateSlider.minimumValue {
//            inputDate = self.dateSlider.minimumValue
//        } else if inputDate > self.dateSlider.maximumValue {
//            inputDate = self.dateSlider.maximumValue
//        }
//        self.dateSlider.setValue(inputDate, animated: true)
//        self.chooseDateTextField.text = String(Int(inputDate))
//    }
    
    func updateSlider() {
        if let date = dateAndAlphaDict["date"] {
            dateSlider.setValue(Float(date)!, animated: true)
        }
        
        if let alpha = dateAndAlphaDict["alpha"] {
            alphaSlider.setValue(Float(alpha)!, animated: true)
        }
    }
    
    func addOverlay() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        let overlay = HistoryMapOverlay(historyMap: historyMap)
        mapView.addOverlay(overlay)
    }
    
    func addInformationPins() {
        var coordinate = CLLocationCoordinate2DMake(40.72422, -74.22544)
        var title = "Newark"
        var subtitle = "This is a test"
        var annotation = InformationAnnotation(coordinate: coordinate, title: title, subtitle: subtitle)
        mapView.addAnnotation(annotation)
        
        coordinate = CLLocationCoordinate2DMake(40.712216, -74.22655)
        title = "Newark1"
        subtitle = "This is a test1"
        annotation = InformationAnnotation(coordinate: coordinate, title: title, subtitle: subtitle)
        mapView.addAnnotation(annotation)
        
        coordinate = CLLocationCoordinate2DMake(40.773941, -74.12544)
        title = "Newark2"
        subtitle = "This is a test2"
        annotation = InformationAnnotation(coordinate: coordinate, title: title, subtitle: subtitle)
        mapView.addAnnotation(annotation)
    }
    
    // TODO: add share function
    func share() {
        UIGraphicsBeginImageContext(drawMapImageView.bounds.size)
        drawMapImageView.image?.drawInRect(CGRect(x: 0, y: 0,
            width: drawMapImageView.frame.size.width, height: drawMapImageView.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(activity, animated: true, completion: nil)
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
    
    func donePicker() {
        dateAndAlphaDict["date"] = newDateAndAlphaDict["date"]
        dateAndAlphaDict["alpha"] = newDateAndAlphaDict["alpha"]
        if let date = dateAndAlphaDict["date"], let alpha = dateAndAlphaDict["alpha"] {
            updateMap(date)
            chooseDateTextField.text = "\(date) + \(alpha)"
        }
        updateSlider()
        chooseDateTextField.resignFirstResponder()
    }
    
    func resetDrawing() {
        drawMapImageView.image = historyMapImage
    }
    
//    func photoPicked() {
//        
//    }
    
    func getMoreInformation() {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTools" {
            let vc = segue.destinationViewController as! ToolsTableViewController
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
            
            vc.delegate = self
            vc.brush = brushWidth
            vc.opacity = opacity
            vc.red = red
            vc.green = green
            vc.blue = blue
        } else if segue.identifier == "ShowAnnotationDetails" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let vc = navigationController.topViewController as! AnnotationDetailsTableViewController
            let annotation = sender as! InformationAnnotation
            vc.annotation = annotation
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        picker.selectRow(data.indexOf(dateAndAlphaDict["date"]!)!, inComponent: 0, animated: true)
        picker.selectRow(alpha.indexOf(dateAndAlphaDict["alpha"]!)!, inComponent: 1, animated: true)
        print("beigin editing")
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
//        let annotationView = InformationAnnotationView(annotation: annotation, reuseIdentifier: "Information")
//        annotationView.canShowCallout = true
        
        let identifier = "Information"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.pinTintColor = UIColor.orangeColor()
            annotationView?.canShowCallout = true
            
            let button = UIButton(type: .DetailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView?.annotation = annotation
        }
        
//        let smallSquare = CGSize(width: 30, height: 30)
//        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
//        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
//        button.addTarget(self, action: Selector("getMoreInformation"), forControlEvents: .TouchUpInside)
//        pinView?.leftCalloutAccessoryView = button
        return annotationView
        
//        return annotationView
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
        let mapRect = mapView.visibleMapRect;
        let eastPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMidY(mapRect));
        let westPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMidY(mapRect));
        let currentMapDist = MKMetersBetweenMapPoints(eastPoint, westPoint);
//        if mapView.overlays.count > 0 {
//            let overlaysOrigin = mapView.overlays[0].coordinate
//            let aaa = mapView.convertCoordinate(overlaysOrigin, toPointToView: containerView)
//            print("center \(aaa)")
//            let overlayRect = mapView.overlays[0].boundingMapRect
//            let region = MKCoordinateRegionForMapRect(overlayRect)
//            let rect = mapView.convertRegion(region, toRectToView: containerView)
//            print("rect \(rect)")
//        }
        print("Current map distance is \(currentMapDist)");
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
        } else {
            return alpha.count
        }
    }
    
    
}

// MARK: - UIPickerViewDelegate

extension MapViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            newDateAndAlphaDict["date"] = data[row]
        } else {
            newDateAndAlphaDict["alpha"] = alpha[row]
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
            return pickerWidth/3 * 2
        } else {
            return pickerWidth/3
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

extension MapViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return drawMapImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let boundsSize = self.scrollView.bounds.size
        let contentFrame = drawMapImageView.frame
        
//        if contentFrame.size.width < boundsSize.width {
//            contentFrame.origin.x = (boundsSize.width - contentFrame.size.width)/2
//        } else {
//            contentFrame.origin.x = 0.0
//        }
//        
//        if contentFrame.size.height < boundsSize.height {
//            contentFrame.origin.y = (boundsSize.height - contentFrame.size.height)/2
//        } else {
//            contentFrame.origin.y = 0.0
//        }
//        
//        drawMapImageView.frame = contentFrame
        if contentFrame.height < boundsSize.height {
            let shiftHeigh = boundsSize.height/2.0 - self.scrollView.contentSize.height/2.0
            self.scrollView.contentInset.top = shiftHeigh
        }
        if contentFrame.width < boundsSize.width {
            let shiftwidth = boundsSize.width/2.0 - self.scrollView.contentSize.width/2.0
            self.scrollView.contentInset.left = shiftwidth
        }
    }
}

//// MARK: - BrushSettingsViewControllerDelegate
//
//extension MapViewController: BrushSettingsViewControllerDelegate {
//    func brushSettingsviewControllerFinished(brushSettingsViewController: BrushSettingsViewController) {
//        brushWidth = brushSettingsViewController.brush
//        opacity = brushSettingsViewController.opacity
//    }
//}

// MARK: - PhotoPickedDelegate

extension MapViewController: PhotoPickedDelegate {
    func photoPicked(image: UIImage) {
        historyMapImage = image
//        overlayView?.overlayImage = historyMapImage!
        mapView.removeOverlays(mapView.overlays)
        scrollView.hidden = false
        scrollView.userInteractionEnabled = true
        mapView.userInteractionEnabled = true
        drawMapImageView.hidden = false
        drawMapImageView.hidden = false
        drawMapImageView.image = historyMapImage
        drawMapImageView.userInteractionEnabled = false
    }
}

// MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
