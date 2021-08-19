//
//  RatingCell.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 13/10/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class RatingCell: UITableViewCell {

    @IBOutlet weak var trailerImage: UIImageView!
    @IBOutlet weak var trailerName: UILabel!
    @IBOutlet weak var trailerSubtitle: UILabel!
        
    @IBOutlet weak var detailsButton: UIButton!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var reviewButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.makeBordered()
        backView.layer.cornerRadius = 8
        trailerImage.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
