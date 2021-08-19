//
//  ConfirmationLocationTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 26/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class ConfirmationLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var location: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        locationView.layer.cornerRadius = 12
        locationView.makeBordered()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
