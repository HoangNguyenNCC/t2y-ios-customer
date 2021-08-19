//
//  UpsellItemCollectionViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 11/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

enum UpsellItemState : String{
    case added = "Added"
    case notAdded = "Add"
}

class UpsellItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemState: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var upsellImage: UIImageView!
    var state: UpsellItemState = .notAdded
    
    override func awakeFromNib() {
        itemState.text = state.rawValue
        itemState.layer.cornerRadius = itemState.frame.height/2
    }
    
    override func layoutSubviews() {
        itemState.layer.masksToBounds = true
    }
    
    func changeState() {
        if state == .notAdded {
            state = .added
            itemState.textColor = #colorLiteral(red: 0, green: 0.2, blue: 0.7450980392, alpha: 1)
            itemState.backgroundColor = .secondarySystemBackground
        }
        else {
            state = .notAdded
            itemState.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            itemState.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.5843137255, blue: 1, alpha: 1)
        }
        itemState.text = state.rawValue
    }
    
    
}
