//
//  FilterItemTableViewCell.swift
//  Trailer2You
//
//  Created by Aritro Paul on 22/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class FilterItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    var item = FilterItems()
    var isChecked = false
    
    @objc func check() {
        if isChecked{
            checkButton.setImage(UIImage(systemName: Symbol.square.rawValue), for: .normal)
            isChecked = false
            checkButton.tintColor = .secondarySystemFill
        }
        else {
            checkButton.setImage(UIImage(systemName: Symbol.checked.rawValue), for: .normal)
            checkButton.tintColor = .primary
            isChecked = true
        }
    }
    
    func reuse() {
        if isChecked {
            checkButton.setImage(UIImage(systemName:Symbol.checked.rawValue), for: .normal)
            checkButton.tintColor = .primary
        }
        else {
            checkButton.setImage(UIImage(systemName: Symbol.square.rawValue), for: .normal)
            checkButton.tintColor = .secondarySystemFill
        }
    }
    
    func reset() {
        checkButton.setImage(UIImage(systemName: Symbol.square.rawValue), for: .normal)
        checkButton.tintColor = .secondarySystemFill
    }
    
    @IBAction func checkTapped(_ sender: Any) {
    }
    
}
