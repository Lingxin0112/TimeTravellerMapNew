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
    
    var map: Map?
    
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
        nameLabel.text = map?.name
        areaLabel.text = map?.area
        dateLabel.text = map?.date
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
