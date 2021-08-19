//
//  LocationTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 16/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.cornerRadius = 8
        self.backView.layer.borderWidth = 2
        self.backView.layer.borderColor = UIColor.systemGray5.cgColor
        self.locationIcon.layer.cornerRadius = 8
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
