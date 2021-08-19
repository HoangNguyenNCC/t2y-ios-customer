//
//  Date.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 25/07/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

extension Date {
    func addYears(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .year, value: n, to: self)!
    }
    
    func addHours(n : Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .hour, value: n, to: self)!
    }
    
    func getDOB()->String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: self)
        return date
    }
}
