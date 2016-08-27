//
//  MapDrawingViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 08/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import MapKit

class MapDrawingViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var drawingView: UIView!
    @IBOutlet weak var mapDrawingImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var image: UIImage?
    var coordinateRegion: MKCoordinateRegion?
    
    // map drawing
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    var isExistedMap: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapDrawingImageView.image = image
        tempImageView.image = image
//        mapView.userInteractionEnabled = false
        mapView.setRegion(coordinateRegion!, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("MapDrawingViewController deinit")
    }
    
    @IBAction func Save(sender: UIButton) {
        image = mapDrawingImageView.image
        if isExistedMap {
            performSegueWithIdentifier("SaveExistedMapDrawing", sender: nil)
        } else {
            performSegueWithIdentifier("SaveMapDrawing", sender: nil)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func fullScreen(sender: UIBarButtonItem) {
       isFullScreen = !isFullScreen
    }
    
    var isFullScreen: Bool = false {
        didSet {
            if isFullScreen {
                //                mapDrawingImageView.center = view.center
                //                mapDrawingImageView.frame.size = CGSize(width: 300, height: 240)
                //                tempImageView.center = view.center
                //                tempImageView.frame.size = CGSize(width: 300, height: 240)
                drawingView.center = view.center
                drawingView.frame.size = CGSize(width: 300, height: 240)
//                drawingView.frame = CGRect(x: 0, y: 0, width: 300, height: 240)
            } else {
                drawingView.removeConstraints(drawingView.constraints)
                drawingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 64)
            }
            mapDrawingImageView.frame = drawingView.bounds
            tempImageView.frame = drawingView.bounds
        }
    }
    
    
    @IBAction func reset(sender: UIBarButtonItem) {
        mapDrawingImageView.image = image
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.locationInView(drawingView)
            if drawingView.frame.contains(lastPoint) {
                mapView.userInteractionEnabled = false
            }
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(drawingView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: drawingView.frame.size.width, height: drawingView.frame.size.height))
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, .Normal)
        
        CGContextStrokePath(context)
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(drawingView)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(drawingView.frame.size)
        mapDrawingImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: drawingView.frame.size.width, height: drawingView.frame.size.height), blendMode: .Normal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: drawingView.frame.size.width, height: drawingView.frame.size.height), blendMode: .Normal, alpha: opacity)
        mapDrawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        tempImageView.image = nil
        mapView.userInteractionEnabled = true
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BrushSetting" {
            let nvController = segue.destinationViewController as! UINavigationController
            let vc = nvController.topViewController as! BrushSettingsViewController
            vc.brush = brushWidth
            vc.opacity = opacity
            vc.red = red
            vc.green = green
            vc.blue = blue
        } else if segue.identifier == "SaveMapDrawing" {
            let controller = segue.destinationViewController as! MapLocationViewController
            controller.image = image
        } else if segue.identifier == "SaveExistedMapDrawing" {
            let controller = segue.destinationViewController as! AddMapViewController
            controller.image = image
        }
    }

}
