//
//  ToolsTableViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 01/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

protocol PhotoPickedDelegate: class {
    func photoPicked(image: UIImage)
}

class ToolsTableViewController: UITableViewController {
    
    enum ToolType {
        
        enum Tools {
            case pencil
            case photo
            case zoom
        }
        
        enum MapType {
            case Standard
            case Hybrid
            case Satellite
        }
        
        enum Others {
            case share
            case reset
            case overlay
        }
    }
    
    let tools = ["pencil", "photo", "zoom"]
    let newTools = ["sahre", "reset", "overlay"]
    let mapTypes = ["standard", "hybrid", "satellite"]
    var tool: String?
    var mapType: String?
    
    var brush: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
    var image: UIImage?
    weak var delegate: PhotoPickedDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        } else if section == 1{
            return 3
        } else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            choosePhoto()
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChooseTool" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) where indexPath.section == 0{
                tool = tools[indexPath.row]
            } else if let indexPath = tableView.indexPathForCell(cell) where indexPath.section == 1 {
                tool = newTools[indexPath.row]
            }
        } else if segue.identifier == "BrushSetting" {
            let vc = segue.destinationViewController as! BrushSettingsViewController
//            vc.delegate = self
            vc.brush = brush
            vc.opacity = opacity
            vc.red = red
            vc.green = green
            vc.blue = blue
        } else if segue.identifier == "ChooseMapType" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) where indexPath.section == 2{
                mapType = mapTypes[indexPath.row]
            }
        }
    }

}

//// MARK: - BrushSettingsViewControllerDelegate
//
//extension ToolsTableViewController: BrushSettingsViewControllerDelegate {
//    func brushSettingsviewControllerFinished(brushSettingsViewController: BrushSettingsViewController) {
//        brush = brushSettingsViewController.brush
//        opacity = brushSettingsViewController.opacity
//    }
//}

extension ToolsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func chooseFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            chooseFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in
            self.takePhotoWithCamera()
        })
        let chooseFromLibraryAction = UIAlertAction(title: "Photo Library", style: .Default, handler: { _ in
            self.chooseFromLibrary()
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        controller.addAction(takePhotoAction)
        controller.addAction(chooseFromLibraryAction)
        controller.addAction(cancelAction)
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let image = image {
            delegate?.photoPicked(image)
        }
        dismissViewControllerAnimated(true, completion: {_ in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: {_ in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}

