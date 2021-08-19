//
//  String.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 02/09/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

extension String {
    var formattedValue : String {
        var value = self
        value = value.replacingOccurrences(of: "lbs", with: "")
        
        let number = Int(value)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if let num = number{
        return (numberFormatter.string(from: NSNumber(value: num)) ?? value) + " lbs"
        } else {
            return self
        }
    }
}
