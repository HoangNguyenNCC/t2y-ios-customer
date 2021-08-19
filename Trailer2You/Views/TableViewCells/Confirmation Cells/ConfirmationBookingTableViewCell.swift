//
//  ConfirmationBookingTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 26/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class ConfirmationBookingTableViewCell: UITableViewCell {

    @IBOutlet weak var bookingView: UIView!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var fromTime: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var toTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookingView.layer.cornerRadius = 12
        bookingView.makeBordered()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
