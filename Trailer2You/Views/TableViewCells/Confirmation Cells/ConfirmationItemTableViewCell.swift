//
//  ConfirmationItemTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 26/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class ConfirmationItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
