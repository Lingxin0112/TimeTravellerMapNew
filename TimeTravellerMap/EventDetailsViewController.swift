//
//  EventDetailsViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 15/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData

class EventDetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var areaLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var longtitudeLabel: UILabel!
    
    @IBOutlet weak var videoUrlLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var videoWebView: UIWebView!
    
    @IBOutlet weak var usefulLinksLabel: UILabel!
    var event: Event?
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureInterface()
        let editBarItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editEvent"))
        navigationItem.rightBarButtonItem = editBarItem
    }
    
    func editEvent() {
        performSegueWithIdentifier("EditEvent", sender: event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Function
    func configureInterface() {
        if let event = event {
            nameLabel.text = event.name
            dateLabel.text = event.date
            areaLabel.text = event.area
            videoUrlLabel.text = event.videoURL
            latitudeLabel.text = String(format: "%.8f", event.latitude)
            longtitudeLabel.text = String(format: "%.8f", event.longtitude)
            descriptionLabel.text = event.eventDescription
            var userfulLinks = ""
            var count = 0
            for linkTemp in event.links! {
                let link = linkTemp as! Link
                count += 1
                userfulLinks += "\(count). " + link.address! + "\n"
            }

            usefulLinksLabel.text = userfulLinks
        }
    }

    // MARK: - Navigation
    
    @IBAction func updateEvent(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! AddEventTableViewController
        event = controller.event
        configureInterface()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditEvent" {
            let naviController = segue.destinationViewController as! UINavigationController
            let vc = naviController.topViewController as! AddEventTableViewController
            vc.managedContext = managedContext
            vc.eventToEdit = event
        }
    }

}
