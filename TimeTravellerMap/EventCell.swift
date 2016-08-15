//
//  EventCell.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 15/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = UIColor.blackColor()
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.highlightedTextColor = nameLabel.textColor
        dateLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        dateLabel.highlightedTextColor = dateLabel.textColor
        areaLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        areaLabel.highlightedTextColor = areaLabel.textColor
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellForEvent(event: Event) {
        nameLabel.text = event.name
        dateLabel.text = event.date
        areaLabel.text = event.area
    }

}
