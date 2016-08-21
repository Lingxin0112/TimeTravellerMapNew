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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var drawMapImageView: UIImageView!
//    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    

    let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    var historyMap = HistoryMap()
    var overlayView: HistoryMapOverlayView?
    var historyMapImage: UIImage?
    
//    lazy var data: [String] = {
//        var dataArray = [String]()
//        for i in -338...1500 {
//            dataArray.append("\(i)")
//        }
//        
//        return dataArray
//    }()
    var data: [String] = []
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
    
    let oldImageView = UIImageView()
    let newImageView = UIImageView()
    let testImageView = UIImageView()
//    let oldImageview = UIImageView(image: UIImage(named: "Newark1800.jpg"))
//    let newImageView = UIImageView(image: UIImage(named: "Newark1916"))
    let animationView = UIView()
    
    var oldYear = 1500
    var newYear = -330
    
    var state: String = "first"
    
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
        
        historyMapImage = UIImage(named: "Newark1800.jpg")
        
        // 
        let latDelta = historyMap.southWestCoordinate.latitude -
            historyMap.northEastCoordinate.latitude
        
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
//        mapView.showsTraffic = true
        
        addOverlay()
        print(overlayView?.overlayImage.size)
        
        // picker
        picker.delegate = self
        picker.dataSource = self
        chooseDateTextField.inputView = picker
        picker.selectRow(2, inComponent: 0, animated: true)
        picker.selectRow(2, inComponent: 1, animated: true)
        picker.selectRow(2, inComponent: 2, animated: true)
        
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
        
        animationView.hidden = true
        containerView.addSubview(animationView)
        oldImageView.hidden = true
//        containerView.addSubview(oldImageView)
        newImageView.hidden = true
        containerView.addSubview(newImageView)
        animationView.addSubview(oldImageView)
        
        loadMaps()
        overlayView?.accessibilityLabel = "overlayView"
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
        if isLaunch {

            let launchView = LaunchView.launchView(view, animated: true)
            let window = UIApplication.sharedApplication().keyWindow
                        window?.addSubview(launchView)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "Launch")
        }
        
        mapView.removeAnnotations(mapView.annotations)
        state = "refresh"
//        addInformationPins()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func dateSliderChanged(sender: UISlider) {
        let year = String(Int(self.dateSlider.value))
        var ascending: Bool = false
        if Int(year)! > Int(dateAndAlphaDict["date"]!) {
            ascending = true
        } else {
            ascending = false
        }
        dateAndAlphaDict["date"] = year
        self.chooseDateTextField.text = "\(dateAndAlphaDict["date"]!) + \(dateAndAlphaDict["alpha"]!)"
        
//        newYear = Int(self.dateSlider.value)
        updateMap(year, ascending: ascending)
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
        }
        dateSlider.value = dateSlider.maximumValue
        
        dateAndAlphaDict["date"] = String(Int(self.dateSlider.maximumValue))
        dateAndAlphaDict["alpha"] = String(format: "%.1f", Float(self.alphaSlider.maximumValue))
        
        self.chooseDateTextField.text = "\(dateAndAlphaDict["date"]!) + \(dateAndAlphaDict["alpha"]!)"
        newDateAndAlphaDict["date"] = dateAndAlphaDict["date"]
        newDateAndAlphaDict["alpha"] = dateAndAlphaDict["alpha"]
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
        
        let annotationStoryboard = UIStoryboard(name: "Annotation", bundle: nil)
        let navigationControoler = annotationStoryboard.instantiateViewControllerWithIdentifier("AddEventNavigationController") as! UINavigationController
        let controller = navigationControoler.topViewController as! AddEventTableViewController
        controller.managedContext = managedContext
        
        controller.coordinate = coordinate
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
    
    @IBAction func chooseTool(segue: UIStoryboardSegue) {
        if segue.identifier == "ChooseTool" {
            let controller = segue.sourceViewController as! ToolsTableViewController
            let tool = controller.tool
            print(tool)
            if tool == "pencil" {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: Selector("saveDrawImageOverlay"))
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
                if let historyMapImage = historyMapImage {
                    overlayView?.overlayImage = historyMapImage
                }
                
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
                historyMap.midCoordinate = mapView.centerCoordinate
                historyMap.overlayBoudingMapRect = mapView.visibleMapRect
                
                
        
                addOverlay()
            }
        }
    }
    
//    @IBAction func chooseBrush(segue: UIStoryboardSegue) {
//        if segue.identifier == "ChooseBrush" {
//            let controller = segue.sourceViewController as! BrushSettingsViewController
//            brushWidth = controller.brush
//            opacity = controller.opacity
//            red = controller.red
//            green = controller.green
//            blue = controller.blue
//            print("brushWidth \(controller.brush) + opacity \(controller.opacity)")
//        }
//    }
    
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
    
    var testOption = 0
    @IBAction func hideOverlay(sender: UIButton) {
        performSegueWithIdentifier("MapsAnimation", sender: nil)
        if testOption > 3 {
            testOption  = 0
        }
//        animationWithMapOverlay(2, ascending: true)
        testOption += 1
        let coordinate = self.overlayView?.overlay.coordinate
        print("Overlay mid coordinate: \(coordinate)")
        
//        let oldImageView = UIImageView(image: UIImage(named: "Newark1800.jpg"))
//        let newImageView = UIImageView(image: UIImage(named: "Newark1916"))
        
//        oldImageView.alpha = 1.0
//        newImageView.alpha = 0.0
        
//        let overlayRect = overlayView!.overlay.boundingMapRect
//        let region = MKCoordinateRegionForMapRect(overlayRect)
//        let rect = mapView.convertRegion(region, toRectToView: containerView)
////        print("rect \(rect)")
////        let animationView = UIView(frame: rect)
//        animationView.frame = rect
//        oldImageView.frame = animationView.bounds
//        newImageView.frame = animationView.bounds
//        animationView.backgroundColor = UIColor.blueColor()
//        animationView.addSubview(oldImageView)
//        self.animationView.hidden = false
//        overlayView?.alpha = 0.0
//        containerView.addSubview(newImageView)
//        containerView.addSubview(oldImageView)
        
//        containerView.addSubview(newImageView)
//        oldImageView.frame = rect
//        newImageView.frame = rect
//        newImageView.center.x -= 150
//        containerView.addSubview(oldImageView)
//        containerView.addSubview(newImageView)
//        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseInOut, animations: {
//            newImageView.alpha = 1.0
////            oldImageView.alpha = 0.0
//            oldImageView.center.x += 150
//            newImageView.center.x += 150
//            self.overlayView?.overlayImage = UIImage(named: "Newark1916")!
//            }, completion: { _ in
//                self.overlayView?.alpha = 1.0
//                newImageView.alpha = 0.0
//                newImageView.removeFromSuperview()
//                oldImageView.removeFromSuperview()
//        })
//
        
//        UIView.transitionWithView(animationView, duration: 2, options: [.CurveEaseOut, .TransitionFlipFromBottom], animations: {
//                self.newImageView.hidden = false
//                self.animationView.addSubview(self.newImageView)
//            }, completion: { _ in
//                self.overlayView?.alpha = 0.0
//            }
//        )
        
//        UIView.transitionWithView(newImageView, duration: 2, options: [.CurveEaseOut, .TransitionCurlDown], animations: {
//            self.newImageView.hidden = false
//            }, completion: nil)
    
//        UIView.transitionFromView(oldImageView, toView: newImageView, duration: 2, options: [.TransitionCurlDown], completion: nil)
        
//        UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseOut, animations: {
//            newImageView.alpha = 0.0
//            oldImageView.alpha = 0.0
//            self.overlayView?.alpha = 1.0
//            }, completion: { _ in
//        })
    }
    
    // TODO: Need to test in the real device
    func saveDrawImageOverlay() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            UIImageWriteToSavedPhotosAlbum(self.drawMapImageView.image!, nil, nil, nil)
        }
    }
    
    // MARK: - Animation of map overlay
    func animationWithMapOverlay(option: Int, ascending: Bool) {
//        oldImageView.image = UIImage(named: "Newark1800.jpg")
//        newImageView.image = UIImage(named: "RE-812ad")
        let overlayRect = overlayView!.overlay.boundingMapRect
        let region = MKCoordinateRegionForMapRect(overlayRect)
        let rect = mapView.convertRegion(region, toRectToView: containerView)
    
//        historyMapImage = UIImage(named: "Newark1916")
        
        if option == 0  {
            newImageView.frame = rect
            oldImageView.frame = animationView.bounds
            
            if ascending {
                UIView.transitionWithView(newImageView, duration: 2, options: [.CurveEaseOut, .TransitionCurlDown], animations: {
                    self.newImageView.hidden = false
                    self.overlayView?.overlayImage = self.newImageView.image!
                    }, completion: { _ in
                        self.newImageView.hidden = true
                })
            } else {
                oldImageView.hidden = false
                animationView.hidden = false
                UIView.transitionWithView(animationView, duration: 2, options: [.CurveEaseOut, .TransitionCurlUp], animations: {
                    self.oldImageView.removeFromSuperview()
                    self.overlayView?.overlayImage = self.newImageView.image!
                    }, completion: { _ in
                        self.oldImageView.hidden = true
                        self.animationView.hidden = true
                })
            }
        } else if option == 1 {
            animationView.frame = rect
            animationView.hidden = false
            newImageView.frame = animationView.bounds
            UIView.transitionWithView(animationView, duration: 2, options: [.CurveEaseOut, .TransitionFlipFromBottom], animations: {
                    self.newImageView.hidden = false
                    self.animationView.addSubview(self.newImageView)
                }, completion: { _ in
                    self.overlayView?.overlayImage = self.newImageView.image!
                    self.animationView.hidden = true
            })
        } else if option == 2 {
            oldImageView.frame = rect
            newImageView.frame = rect
            oldImageView.hidden = false
            newImageView.hidden = false
            
            containerView.addSubview(oldImageView)
            containerView.addSubview(newImageView)
            overlayView?.alpha = 0.0
            
            if ascending {
                newImageView.center.x -= 300
                UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.newImageView.alpha = 1.0
                    self.oldImageView.center.x += 300
                    self.newImageView.center.x += 300
                    self.overlayView?.overlayImage = self.newImageView.image!
                    }, completion: { _ in
                        
                        //                    self.newImageView.hidden = true
                        self.oldImageView.hidden = true
                        self.overlayView?.alpha = 1.0
                        //                    self.newImageView.removeFromSuperview()
                        //                    self.oldImageView.removeFromSuperview()
                })
            } else {
                newImageView.center.x += 300
                UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.newImageView.alpha = 1.0
                    self.oldImageView.center.x -= 300
                    self.newImageView.center.x -= 300
                    self.overlayView?.overlayImage = self.newImageView.image!
                    }, completion: { _ in
                        
                        //                    self.newImageView.hidden = true
                        self.oldImageView.hidden = true
                        self.overlayView?.alpha = 1.0
                        //                    self.newImageView.removeFromSuperview()
                        //                    self.oldImageView.removeFromSuperview()
                })

            }
            
            
        } else if option == 3 {
            let imageArray = [oldImageView.image!, newImageView.image!]
            newImageView.hidden = false
            newImageView.animationImages = imageArray
            newImageView.animationDuration = 2.0
            newImageView.startAnimating()
        }
        oldImageView.image = newImageView.image
        
        // 2222222
//        let newRect = mapView.convertRegion(region, toRectToView: view)
//        testImageView.frame = newRect
//        testImageView.image = UIImage(named: "RE-9ad")
//        self.view.addSubview(testImageView)
//        let point = mapView.convertPoint(testImageView.frame.origin, toCoordinateFromView: view)
//        print("newImageview point:\(point)")
//        
//        let newPoint = CGPoint(x: testImageView.frame.origin.x + testImageView.frame.size.width, y: testImageView.frame.origin.y + testImageView.frame.size.height)
//        let eastPoint = mapView.convertPoint(newPoint, toCoordinateFromView: view)
//        print("newImageview SE_point:\(eastPoint)")
    }
    
    func transform(oldMap: Map, newMap: Map, ascending: Bool) {
//        let oldHistoryMap = HistoryMap(map: oldMap)
//        let newHistoryMap = HistoryMap(map: newMap)
//        let oldMapOverlay = HistoryMapOverlay(historyMap: oldHistoryMap)
//        let newMapOverlay = HistoryMapOverlay(historyMap: newHistoryMap)
//        let oldOverlayRect = oldMapOverlay.boundingMapRect
//        let newOverlayRect = newMapOverlay.boundingMapRect
//        let oldRegion = MKCoordinateRegionForMapRect(oldOverlayRect)
//        let newRegion = MKCoordinateRegionForMapRect(newOverlayRect)
        let oldRect = mapView.convertRegion(oldMap.getMapRegion(), toRectToView: containerView)
        let newRect = mapView.convertRegion(newMap.getMapRegion(), toRectToView: containerView)
        
        let oldMapImageView = UIImageView(frame: oldRect)
        let newMapImageView = UIImageView(frame: newRect)
        oldMapImageView.image = UIImage(data: oldMap.mapImageData!)
        newMapImageView.image = UIImage(data: newMap.mapImageData!)
        
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
                    newMapImageView.removeFromSuperview()
                    oldMapImageView.removeFromSuperview()
                    
                    self.overlayView?.alpha = 1.0
            })
        } else {
            newMapImageView.center.x += 300
            UIView.animateWithDuration(2.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                oldMapImageView.center.x -= 300
                newMapImageView.center.x -= 300
//                self.overlayView?.overlayImage = newMapImageView.image!
                }, completion: { _ in
                    newMapImageView.removeFromSuperview()
                    oldMapImageView.removeFromSuperview()
                    self.overlayView?.alpha = 1.0
            })
        }
        
        self.oldMap = self.newMap
        
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
    
    func addMapOverlay(map: Map) {
//        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        historyMap = HistoryMap(map: map)
        let overlay = HistoryMapOverlay(historyMap: historyMap)
        historyMapImage = historyMap.image
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
    
    func updateNewMap(map: Map) {
        if let newImage = UIImage(data: map.mapImageData!) {
            newImageView.image = newImage
            animationWithMapOverlay(0, ascending: false)
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
        
        do {
            let maps = try managedContext.executeFetchRequest(fetchRequest) as! [Map]
            if maps.count == 1 {
                print("find a map:\(maps[0].name!)")
                newMap = maps[0]
                if newMap != oldMap {
                    transform(oldMap!, newMap: newMap!, ascending: ascending)
                }
                
            } else if maps.count > 1 {
                var imageArray : [UIImage] = []
                for map in maps {
                    let image = UIImage(data: map.mapImageData!)
                    imageArray.append(image!)
                }

                if ascending {
                    addMapOverlay(maps[maps.count - 1])
                } else {
                    addMapOverlay(maps[0])
                }
                
                overlayView?.alpha = 1.0
                performSegueWithIdentifier("MapsAnimation", sender: imageArray)
            }
            oldYear = newYear
        } catch {
            fatalError("Error: \(error)")
        }
        
    }
    
    func donePicker() {
        var ascending: Bool = false
        if dateAndAlphaDict["date"] < newDateAndAlphaDict["date"] {
            ascending = true
        } else {
            ascending = false
        }
        dateAndAlphaDict["date"] = newDateAndAlphaDict["date"]
        dateAndAlphaDict["alpha"] = newDateAndAlphaDict["alpha"]
        
        if let date = dateAndAlphaDict["date"], let alpha = dateAndAlphaDict["alpha"] {
            updateMap(date, ascending: ascending)
            chooseDateTextField.text = "\(date) + \(alpha)"
        }
        updateSlider()
        chooseDateTextField.resignFirstResponder()
    }
    
    func resetDrawing() {
        drawMapImageView.image = historyMapImage
    }
    
    func getMoreInformation() {
        
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
            let northEastCoordinate = CLLocationCoordinate2D(latitude: Double(map.neLatitude!), longitude: Double(map.neLongtitude!))
            let southWestCoordinate = CLLocationCoordinate2D(latitude: Double(map.swLatitude!), longitude: Double(map.swLongtitude!))
            
            let southWestPoint = MKMapPointForCoordinate(southWestCoordinate)
            let northEastPoint = MKMapPointForCoordinate(northEastCoordinate)
            
            let mapRect =  MKMapRectMake(southWestPoint.x, northEastPoint.y, fabs(northEastPoint.x - southWestPoint.x), fabs(northEastPoint.y - southWestPoint.y))
            
            if MKMapRectIntersectsRect(visibleRect, mapRect) {
                print("in in in .....")
                map.comment = "Yes"
                localMaps.append(map)
            } else {
                print("out out out .....")
                map.comment = "No"
            }
            
            
            do {
                try managedContext.save()
            } catch {
                fatalError("Error: \(error)")
            }
        }
        
        if maps.count > 0 {
            addMapOverlay(maps[0])
            oldMap = maps[0]
        }
        configureRangeOfDateSlider(localMaps)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Go {
            updateSlider()
            self.chooseDateTextField.resignFirstResponder()
            return true
        }
        
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
//        updateMap(dateAndAlphaDict["date"]!)
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
            annotationView?.tintColor = UIColor(white: 0.0, alpha: 0.5)
            
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
        newImageView.hidden = true
        let mapRect = mapView.visibleMapRect;
        let eastPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMidY(mapRect));
        let westPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMidY(mapRect));
        let currentMapDist = MKMetersBetweenMapPoints(eastPoint, westPoint);

        if state == "first" || state == "search" || state == "refresh" {
            chooseMapInTheArea()
            state = "finish"
        }
        addInformationPins()
        if let view = overlayView where MKMapRectIntersectsRect(mapRect, view.overlay.boundingMapRect) {
            print("In this area!!!!!!")
        }
        
        print("Current map distance is \(currentMapDist)");
    }
}

// MARK: - UIPickerViewDataSource

extension MapViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
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
            newDateAndAlphaDict["date"] = data[row]
        } else if component == 1 {
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
