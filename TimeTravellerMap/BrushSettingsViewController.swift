//
//  BrushSettingsViewController.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 01/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

//protocol  BrushSettingsViewControllerDelegate: class{
//    func brushSettingsviewControllerFinished(brushSettingsViewController: BrushSettingsViewController)
//}

class BrushSettingsViewController: UIViewController {
    
    @IBOutlet weak var sliderBrush: UISlider!
    @IBOutlet weak var sliderOpacity: UISlider!
    
    @IBOutlet weak var imageViewBrush: UIImageView!
    @IBOutlet weak var imageViewOpacity: UIImageView!
    
    @IBOutlet weak var labelBrush: UILabel!
    @IBOutlet weak var labelOpacity: UILabel!
    
    @IBOutlet weak var sliderRed: UISlider!
    @IBOutlet weak var sliderGreen: UISlider!
    @IBOutlet weak var sliderBlue: UISlider!
    
    @IBOutlet weak var labelRed: UILabel!
    @IBOutlet weak var labelGreen: UILabel!
    @IBOutlet weak var labelBlue: UILabel!
    
    var brush: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
//    weak var delegate: BrushSettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sliderBrush.value = Float(brush)
        labelBrush.text = String(format: "%.1f", brush.native)
        sliderOpacity.value = Float(opacity)
        labelOpacity.text = String(format: "%.1f", opacity.native)
        sliderRed.value = Float(red * 255.0)
        labelRed.text = String(format: "%d", Int(sliderRed.value))
        sliderGreen.value = Float(green * 255.0)
        labelGreen.text = String(format: "%d", Int(sliderGreen.value))
        sliderBlue.value = Float(blue * 255.0)
        labelBlue.text = String(format: "%d", Int(sliderBlue.value))
        
        drawPreview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("BrushSettingsViewController deinit")
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
//        delegate?.brushSettingsviewControllerFinished(self)
    }
    
    @IBAction func colorChanged(sender: UISlider) {
        red = CGFloat(sliderRed.value / 255.0)
        labelRed.text = String(format: "%d", Int(sliderRed.value))
        green = CGFloat(sliderGreen.value / 255.0)
        labelGreen.text = String(format: "%d", Int(sliderGreen.value))
        blue = CGFloat(sliderBlue.value / 255.0)
        labelBlue.text = String(format: "%d", Int(sliderBlue.value))
        
        drawPreview()
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        if sender == sliderBrush {
            brush = CGFloat(sender.value)
            labelBrush.text = String(format: "%.2f", brush.native)
        } else {
            opacity = CGFloat(sender.value)
            labelOpacity.text = String(format: "%.2f", opacity.native)
        }
        drawPreview()
    }
    
    func drawPreview() {
        UIGraphicsBeginImageContext(imageViewBrush.frame.size)
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, brush)
        
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextMoveToPoint(context, 45.0, 45.0)
        CGContextAddLineToPoint(context, 45.0, 45.0)
        CGContextStrokePath(context)
        imageViewBrush.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContext(imageViewBrush.frame.size)
        context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineCap(context, .Round)
        CGContextSetLineWidth(context, 20)
        CGContextMoveToPoint(context, 45.0, 45.0)
        CGContextAddLineToPoint(context, 45.0, 45.0)
        
        CGContextSetRGBStrokeColor(context, red, green, blue, opacity)
        CGContextStrokePath(context)
        imageViewOpacity.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
     }
    
}



