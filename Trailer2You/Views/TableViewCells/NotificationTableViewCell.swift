//
//  NotificationTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 07/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

enum TrailerRentalStatus : String {
    case ongoing
    case upcoming
    case waiting
    case denied
}


class NotificationTableViewCell: UITableViewCell {
    
    var days : String?
    
    @IBOutlet weak var trailerImage: UIImageView!
    @IBOutlet weak var trailerName: UILabel!
    @IBOutlet weak var licenseeName: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.makeBordered()
        backView.layer.cornerRadius = 8
        trailerImage.layer.cornerRadius = 8
    }
    
    func setStatus(status: TrailerRentalStatus) {
        if status == .ongoing {
            if Int.parse(from: days ?? "") ?? 0 < 3 {
                daysLabel.textColor = .systemOrange
                statusLabel.textColor = .systemOrange
            }
            else {
                daysLabel.textColor = .systemGreen
                statusLabel.textColor = .systemGreen
            }
        }
        else if status == .upcoming{
            daysLabel.textColor = .systemGreen
            statusLabel.textColor = .systemGreen
        }
        else {
            daysLabel.textColor = .systemRed
            statusLabel.textColor = .systemRed
        }
        
        if status == .waiting {
            daysLabel.textColor = .systemOrange
            statusLabel.textColor = .systemOrange
        }
        
        if status == .denied {
            daysLabel.textColor = .systemRed
            statusLabel.textColor = .systemRed
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
