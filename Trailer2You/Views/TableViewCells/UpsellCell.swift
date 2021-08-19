//
//  UpsellCell.swift
//  Trailer2You
//
//  Created by Pranav Karnani on 21/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

protocol UpsellDelegate : class {
    func didAddUpsell(_ tag: Int)
}

class UpsellCell: UITableViewCell {

    weak var cellDelegate: UpsellDelegate?
    var quantity: Int?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var upsellImage: UIImageView!
    @IBOutlet weak var upsellDescription: UILabel!
    @IBOutlet weak var upsellItemCost: UILabel!
    @IBOutlet weak var addItem: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        upsellImage.layer.cornerRadius = 12
        upsellImage.layer.borderColor = UIColor.tertiarySystemFill.cgColor
        upsellImage.layer.borderWidth = 1.5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addItemTapped(_ sender: UIButton) {
        cellDelegate?.didAddUpsell(sender.tag)
    }
    
}
