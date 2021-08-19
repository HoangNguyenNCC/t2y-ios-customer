//
//  RentalTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 28/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class RentalTableViewCell: UITableViewCell {

    @IBOutlet weak var trailerImage: UIImageView!
    @IBOutlet weak var trailerName: UILabel!
    @IBOutlet weak var trailerOwner: UILabel!
    @IBOutlet weak var daysLabel1: UILabel!
    @IBOutlet weak var daysLabel2: UILabel!
    @IBOutlet weak var CTAButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
