//
//  AddMapViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 25/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData

class AddMapViewController: UIViewController {
    
    @IBOutlet weak var areaTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    var map: Map?
    var mapToEdit: Map?
    
    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let map = mapToEdit {
            nameTextField.text = map.name
            areaTextField.text = map.area
            dateTextField.text = map.date
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func done(sender: UIBarButtonItem) {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        
        if let mapToEdit = mapToEdit {
            hudView.text = "Updated"
            map = mapToEdit
        } else {
            hudView.text = "Saved"
            map = NSEntityDescription.insertNewObjectForEntityForName("Map", inManagedObjectContext: managedContext) as! Map
        }
        
        map!.name = nameTextField.text
        map!.area = areaTextField.text
        map!.date = dateTextField.text
        
        do {
            try managedContext.save()
            if let _ = mapToEdit {
                performSegueWithIdentifier("UpdateMap", sender: self)
            }
        } catch {
            fatalError("Error: \(error)")
        }
        
        afterDelay(0.6, closure: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Function
    func afterDelay(seconds: Double, closure: () -> ()) {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue(), closure)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}
