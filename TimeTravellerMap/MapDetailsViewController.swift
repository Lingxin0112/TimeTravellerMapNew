//
//  MapDetailsViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 31/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData

class MapDetailsViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var areaLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    var map: Map!
    var scrollView: UIScrollView?
    var newImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureInterface()
        
        let editBarItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editMap"))
        navigationItem.rightBarButtonItem = editBarItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Function
    
    func editMap() {
        performSegueWithIdentifier("EditMap", sender: map)
    }
    
    func configureInterface() {
        nameLabel.text = map.name
        areaLabel.text = map.area
        dateLabel.text = "\(map.era!)\(String(abs(Int(map.year!))))"
        mapImageView.image = UIImage(data: map!.mapImageData!)
    }
    
    
    @IBAction func showMapImageTapGesture(sender: UITapGestureRecognizer) {
        if let _  = mapImageView.image {
            showImage(mapImageView)
        }
    }
    
    var oldframe: CGRect!
    
    func showImage(imageView: UIImageView) {
        let image = imageView.image!;
        let window = UIApplication.sharedApplication().keyWindow;
        let backgroundView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        oldframe = imageView.convertRect(imageView.bounds, toView: window)
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.alpha = 0;
        newImageView = UIImageView(frame: oldframe)
        newImageView!.image = image
        newImageView!.tag = 1
        scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
        scrollView!.addSubview(newImageView!)
        scrollView!.contentSize = newImageView!.image!.size
        backgroundView.addSubview(scrollView!)
        window?.addSubview(backgroundView)
        scrollView!.delegate = self;
        scrollView!.maximumZoomScale=5.0;
        scrollView!.minimumZoomScale=1;
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("hideImage:"))
        backgroundView.addGestureRecognizer(tap)
        UIView.animateWithDuration(0.3, animations: { _ in
            self.newImageView!.frame = CGRectMake(
                0,
                (UIScreen.mainScreen().bounds.size.height - image.size.height*UIScreen.mainScreen().bounds.size.width/image.size.width)/2,
                UIScreen.mainScreen().bounds.size.width,
                image.size.height*UIScreen.mainScreen().bounds.size.width/image.size.width);
            backgroundView.alpha=1;
        })
        
    }
    
    func hideImage(sender: UITapGestureRecognizer) {
        let backgroundView = sender.view;
        let imageView = sender.view?.viewWithTag(1) as! UIImageView
        UIView.animateWithDuration(0.3, animations: { _ in
            imageView.frame = self.oldframe
            backgroundView!.alpha = 0
            }, completion: { _ in
                backgroundView?.removeFromSuperview()
        })
        
    }

    
    // MARK: - Navigation
    
    @IBAction func updateMap(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! AddMapViewController
        map = controller.mapToEdit
        configureInterface()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditMap" {
            let nvController = segue.destinationViewController as! UINavigationController
            let controller = nvController.topViewController as! AddMapViewController
            controller.managedContext = managedContext
            controller.mapToEdit = map
        }
    }

}

extension MapDetailsViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return newImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
        self.newImageView!.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
    }
    
}