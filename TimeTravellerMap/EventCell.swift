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
