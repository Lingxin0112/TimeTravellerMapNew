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
    
    // set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        centerMapOnLocation(initialLocation)
        mapImageView.alpha = 0.6
        
        mapImageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func done(sender: UIBarButtonItem) {
        getTheLocation()
        performSegueWithIdentifier("UpdateMapCoordinate", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getTheLocation() {
        swLocationCoordinate = mapView.convertPoint(mapImageView.frame.origin, toCoordinateFromView: view)
        print("newImageview point:\(swLocationCoordinate)")
        
        let nePoint = CGPoint(x: mapImageView.frame.origin.x + mapImageView.frame.size.width, y: mapImageView.frame.origin.y + mapImageView.frame.size.height)
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UpdateMapCoordinate" {
            let controller = segue.destinationViewController as! AddMapViewController
            controller.neLocationCoordinate = neLocationCoordinate
            controller.swLocationCoordinate = swLocationCoordinate
        }
    }

}
