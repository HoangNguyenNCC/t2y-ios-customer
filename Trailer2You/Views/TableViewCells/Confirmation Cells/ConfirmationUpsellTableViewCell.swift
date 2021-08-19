//
//  ConfirmationUpsellTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 26/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class ConfirmationUpsellTableViewCell: UITableViewCell {

    @IBOutlet weak var upsellImage: UIImageView!
    @IBOutlet weak var upsellName: UILabel!
    @IBOutlet weak var upsellPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        upsellImage.layer.cornerRadius = 8
        upsellImage.makeBordered()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
