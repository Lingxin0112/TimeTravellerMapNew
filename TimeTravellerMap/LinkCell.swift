//
//  LinkCell.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 18/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class LinkCell: UITableViewCell {
    
    
    @IBOutlet weak var linkTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = UIColor.blackColor()
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
