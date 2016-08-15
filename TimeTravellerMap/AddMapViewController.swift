//
//  AddMapViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 25/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class AddMapViewController: UIViewController {
    
    @IBOutlet weak var areaTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    @IBOutlet weak var swLatitudeTextField: UITextField!
    
    @IBOutlet weak var swLongtitudeTextField: UITextField!
    
    @IBOutlet weak var neLatitudeTextField: UITextField!
    
    @IBOutlet weak var neLongtitudeTextField: UITextField!
    
    @IBOutlet weak var eraSegmentedControl: UISegmentedControl!
    
    var neLocationCoordinate: CLLocationCoordinate2D?
    var swLocationCoordinate: CLLocationCoordinate2D?
    
    
//    @IBOutlet weak var scrollView: UIScrollView!
    
    var mapScrollView: UIScrollView?
    var newImageView: UIImageView?
    
    var map: Map?
    var mapToEdit: Map?
    
    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddMapViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddMapViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        view.endEditing(true)
        
        if let map = mapToEdit {
            nameTextField.text = map.name
            areaTextField.text = map.area
            dateTextField.text = String(abs(Int(map.year!)))
            neLatitudeTextField.text = String(map.neLatitude!)
            neLongtitudeTextField.text = String(map.neLongtitude!)
            swLatitudeTextField.text = String(map.swLatitude!)
            swLongtitudeTextField.text = String(map.swLongtitude!)
            if map.era! == "AD" {
                eraSegmentedControl.selectedSegmentIndex = 1
            }
            mapImageView.image = UIImage(data: map.mapImageData!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        map!.era = eraSegmentedControl.titleForSegmentAtIndex(eraSegmentedControl.selectedSegmentIndex)
        if eraSegmentedControl.selectedSegmentIndex == 0 {
            map!.year = -Int(dateTextField.text!)!
        } else {
            map!.year = Int(dateTextField.text!)
        }
        map!.mapImageData = UIImagePNGRepresentation(mapImageView.image!)
        map!.neLatitude = Double(neLatitudeTextField.text!)
        map!.neLongtitude = Double(neLongtitudeTextField.text!)
        map!.swLatitude = Double(swLatitudeTextField.text!)
        map!.swLongtitude = Double(swLongtitudeTextField.text!)

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
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
//    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
//        guard let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
//        let keyboardFrame = value.CGRectValue()
//        
//        var originY: CGFloat = 0
//        if nameTextField.editing {
//            originY = nameTextField.frame.origin.y
//        } else if areaTextField.editing {
//            originY = areaTextField.frame.origin.y
//        } else if dateTextField.editing {
//            originY = dateTextField.frame.origin.y
//        } else if swLatitudeTextField.editing {
//            originY = swLatitudeTextField.frame.origin.y
//        } else if swLongtitudeTextField.editing {
//            originY = swLongtitudeTextField.frame.origin.y
//        } else if neLatitudeTextField.editing {
//            originY = neLatitudeTextField.frame.origin.y
//        } else if neLongtitudeTextField.editing {
//            originY = neLongtitudeTextField.frame.origin.y
//        }
//        
//        let offset = (originY + neLongtitudeTextField.frame.size.height + 64) - (view.frame.size.height - keyboardFrame.height);
//        
//        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue  else {return}
//        
//        if(offset > 0) {
//            UIView.animateWithDuration(duration, animations: { _ in
//                self.view.frame = CGRectMake(0.0, -offset, self.view.frame.size.width, self.view.frame.size.height);
//            })
//        }
//        
//    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        
        var originY: CGFloat = 0
        if nameTextField.editing {
            originY = nameTextField.frame.origin.y
        } else if areaTextField.editing {
            originY = areaTextField.frame.origin.y
        } else if dateTextField.editing {
            originY = dateTextField.frame.origin.y
        } else if swLatitudeTextField.editing {
            originY = swLatitudeTextField.frame.origin.y
        } else if swLongtitudeTextField.editing {
            originY = swLongtitudeTextField.frame.origin.y
        } else if neLatitudeTextField.editing {
            originY = neLatitudeTextField.frame.origin.y
        } else if neLongtitudeTextField.editing {
            originY = neLongtitudeTextField.frame.origin.y
        }
        
        let offset = (originY + neLongtitudeTextField.frame.size.height + 64) - (view.frame.size.height - keyboardFrame.height);
        
        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue  else {return}
        
        if(offset > 0) {
            UIView.animateWithDuration(duration, animations: { _ in
                self.view.frame = CGRectMake(0.0, -offset, self.view.frame.size.width, self.view.frame.size.height);
            })
        }

    }
    
    func keyboardWillHide(notification: NSNotification) {
            if view.frame.origin.y != 0 {
                view.frame.origin.y = 0
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
        mapScrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
        mapScrollView!.addSubview(newImageView!)
        mapScrollView!.contentSize = newImageView!.image!.size
        backgroundView.addSubview(mapScrollView!)
        window?.addSubview(backgroundView)
        mapScrollView!.delegate = self;
        mapScrollView!.maximumZoomScale=5.0;
        mapScrollView!.minimumZoomScale=1;
        
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
    
    @IBAction func updateMapCoordinate(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! MapLocationViewController
        neLocationCoordinate = controller.neLocationCoordinate
        swLocationCoordinate = controller.swLocationCoordinate
        neLatitudeTextField.text = String(neLocationCoordinate!.latitude)
        neLongtitudeTextField.text = String(neLocationCoordinate!.longitude)
        swLatitudeTextField.text = String(swLocationCoordinate!.latitude)
        swLongtitudeTextField.text = String(swLocationCoordinate!.longitude)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChooseMapLocation" {
            let nvController = segue.destinationViewController as! UINavigationController
            let controller = nvController.topViewController as! MapLocationViewController
            controller.image = sender as? UIImage
        }
    }

}

extension AddMapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func chooseFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
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
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        mapImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("ChooseMapLocation", sender: image)
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


