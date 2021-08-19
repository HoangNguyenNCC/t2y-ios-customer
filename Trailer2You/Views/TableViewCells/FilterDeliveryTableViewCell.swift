//
//  FilterDeliveryTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 22/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

protocol DeliveryDelegate: class {
    func didSetDelivery(method : DeliveryMethod)
}

class FilterDeliveryTableViewCell: UITableViewCell {

    @IBOutlet weak var deliverySegment: UISegmentedControl!
    weak var delegate: DeliveryDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let font = UIFont(name: "AvenirNext-Medium", size: 12)
        deliverySegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        deliverySegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        if deliverySegment.selectedSegmentIndex == 0 {
            delegate?.didSetDelivery(method: .pickup)
        }
        else {
            delegate?.didSetDelivery(method: .door2door)
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
