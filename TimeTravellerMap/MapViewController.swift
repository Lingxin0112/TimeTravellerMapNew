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
    @IBOutlet weak var tempImageView: UIImageView!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scrollView.hidden = true
        drawMapImageView.hidden = true
        tempImageView.hidden = true
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 6.0
        
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
        addOverlay()
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
        overlayView?.alpha = CGFloat(Float(alpha)!)
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
    
    @IBAction func chooseTool(segue: UIStoryboardSegue) {
        if segue.identifier == "ChooseTool" {
            let controller = segue.sourceViewController as! ToolsTableViewController
            let tool = controller.tool
            print(tool)
            if tool == "pencil" {
                mapView.removeOverlays(mapView.overlays)
                scrollView.hidden = false
                scrollView.userInteractionEnabled = false
                drawMapImageView.hidden = false
                tempImageView.hidden = false
                mapView.userInteractionEnabled = false
                drawMapImageView.image = historyMapImage
                brushWidth = controller.brush
                opacity = controller.opacity
            } else if tool == "reset" {
                resetDrawing()
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(scrollView)
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(scrollView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, .Normal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 6
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(scrollView)
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
        UIGraphicsBeginImageContext(drawMapImageView.frame.size)
        drawMapImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), blendMode: .Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), blendMode: .Normal, alpha: opacity)
        drawMapImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    
    @IBAction func hideOverlay(sender: UIButton) {
        let secondImageView = UIImageView(image: UIImage(named: "Newark1916"))
        secondImageView.alpha = 0.0
        secondImageView.frame = CGRectMake(100, 50, 200, 100)
        view.addSubview(secondImageView)
        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
            secondImageView.alpha = 1.0
            }, completion: { _ in
        })
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
            secondImageView.alpha = 0.0
            self.overlayView?.overlayImage = secondImageView.image!
            }, completion: { _ in
                secondImageView.removeFromSuperview()
        })
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTools" {
            let vc = segue.destinationViewController as! ToolsTableViewController
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
            vc.brush = brushWidth
            vc.opacity = opacity
            vc.red = red
            vc.green = green
            vc.blue = blue
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
            historyMapImage = UIImage(named: "Newark1800.jpg")
            let overlayView = HistoryMapOverlayView(overlay: overlay, overlayImage: historyMapImage!)
//            overlayView.alpha = 1.0
            self.overlayView = overlayView
            return overlayView
        } 
        
        return MKOverlayRenderer()
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapRect = mapView.visibleMapRect;
        let eastPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMidY(mapRect));
        let westPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMidY(mapRect));
        let currentMapDist = MKMetersBetweenMapPoints(eastPoint, westPoint);
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
