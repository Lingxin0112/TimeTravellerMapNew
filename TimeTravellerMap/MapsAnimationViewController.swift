//
//  MapsAnimationViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 11/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class MapsAnimationViewController: UIViewController {

    @IBOutlet weak var mapImageView: UIImageView!
    var imageArray: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.clearColor()
        
        mapImageView.animationImages = imageArray
        mapImageView.animationDuration = Double(imageArray!.count)
        mapImageView.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    // MARK: - Action
    
    @IBAction func close(sender: AnyObject) {
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

extension MapsAnimationViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return MyPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}
