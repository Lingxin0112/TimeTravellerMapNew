//
//  TestViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 23/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class TestViewController: UIViewController {

    var mapView: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView = MKMapView(frame: view.bounds)
        mapView!.mapType = .Standard
        mapView!.delegate = self
        view.insertSubview(mapView!, atIndex: 0)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        mapView!.removeFromSuperview()
        mapView!.delegate = nil
        mapView = nil
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TestViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeFromSuperview()
        view.insertSubview(mapView, atIndex: 0)
    }
}