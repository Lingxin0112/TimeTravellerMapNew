//
//  LaunchViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 20/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loading() {
        let image = UIImage(named: "RE-9ad")
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: -20, y: view.bounds.height/2 - 20,
                                 width: 40, height: 40)
        UIView.animateWithDuration(2, animations: { _ in
            imageView.center.x += self.view.bounds.width
        })
        
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
