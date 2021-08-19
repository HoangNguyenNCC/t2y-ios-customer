//
//  TrailerDetailsController+KoyomiDelegate.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import Koyomi

extension TrailerDetailsViewController : KoyomiDelegate {
    
    func koyomi(_ koyomi: Koyomi, shouldSelectDates date: Date?, to toDate: Date?, withPeriodLength length: Int) -> Bool {
        // check for validity
        return true
    }
    
    func koyomi(_ koyomi: Koyomi, fontForItemAt indexPath: IndexPath, date: Date) -> UIFont? {
        return UIFont(name: "AvenirNext-Regular", size: 10)
    }
    
}
