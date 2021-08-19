//
//  FeaturedCollectionViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 10/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import ProgressHUD

class FeaturedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var trailerImageView: UIImageView!
    @IBOutlet weak var trailerNameLabel: UILabel!
    @IBOutlet weak var trailerPricingLabel: UILabel!
    
    override func layoutSubviews() {
        trailerImageView.makeCard()
        trailerImageView.contentMode = .scaleAspectFill
        trailerImageView.layer.cornerRadius = 8
    }
    
    override func awakeFromNib() {
       
    }
    
}
