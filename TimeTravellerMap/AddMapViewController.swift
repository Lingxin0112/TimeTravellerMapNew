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
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    var scrollView: UIScrollView?
    var newImageView: UIImageView?
    
    var map: Map?
    var mapToEdit: Map?
    
//    lazy var data: [String] = {
//        var dataArray = [String]()
//        for i in 1800...2016 {
//            dataArray.append("\(i)")
//        }
//        return dataArray
//    }()
    
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
        map!.mapImageData = UIImagePNGRepresentation(mapImageView.image!)

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
    
    
    @IBAction func pickMapImageLongPressGesture(sender: UILongPressGestureRecognizer) {
        choosePhoto()
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

extension AddMapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        mapImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddMapViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return newImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
        self.newImageView!.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
    }

}


