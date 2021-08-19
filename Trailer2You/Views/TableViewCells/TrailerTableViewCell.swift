//
//  TrailerTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 10/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class TrailerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trailerNameLabel: UILabel!
    @IBOutlet weak var trailerOwnerLabel: UILabel!
    @IBOutlet weak var trailerImageView: UIImageView!
    @IBOutlet weak var trailerPriceLabel: UILabel!
    @IBOutlet weak var trailerDistanceLabel: UILabel!
    @IBOutlet weak var upsellsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        upsellsLabel.layer.cornerRadius = 4
        upsellsLabel.clipsToBounds = true
    }
    
    func setUpsellLabel(_ status: Bool) {
        upsellsLabel.backgroundColor = .secondary
    }
    
    override func layoutSubviews() {
        trailerImageView.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
