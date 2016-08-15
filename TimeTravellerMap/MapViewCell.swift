//
//  MapViewCell.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 31/07/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import UIKit

class MapViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        mapImageView.layer.cornerRadius = 
        
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

    func configureMapForCell(map: Map) {
        nameLabel.text = map.name
        dateLabel.text = "\(map.era!)\(String(abs(Int(map.year!))))"
        areaLabel.text = map.area
        mapImageView.image = UIImage(data: map.mapImageData!)
    }
}
