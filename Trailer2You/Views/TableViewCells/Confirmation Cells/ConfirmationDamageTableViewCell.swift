//
//  ConfirmationDamageTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 26/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class ConfirmationDamageTableViewCell: UITableViewCell {

    @IBOutlet weak var DLRPrice: UILabel!
    @IBOutlet weak var DLRText: UILabel!
    @IBOutlet weak var DLRstatus: UILabel!
    
    func setDLR() {
        DLRstatus.text = "Added"
        DLRstatus.textColor = .white
        DLRstatus.backgroundColor = .primary
    }
    
    func removeDLR(_ reschedule : Bool) {
        DLRstatus.text = reschedule ? "Not Added" : "Tap to Add"
        DLRstatus.textColor = .label
        DLRstatus.backgroundColor = .systemGray6
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
